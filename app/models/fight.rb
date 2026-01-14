class Fight < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include OnboardingTrackable
  include CacheVersionable

  belongs_to :campaign
  has_many :shots, dependent: :destroy
  has_many :characters, through: :shots
  has_many :vehicles, through: :shots
  has_many :effects, dependent: :destroy
  has_many :character_effects, through: :shots
  has_many :fight_events, dependent: :destroy
  has_one_attached :image

  after_update :enqueue_discord_notification
  after_update :broadcast_update
  after_touch :broadcast_encounter_update!

  has_many :image_positions, as: :positionable, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validate :associations_belong_to_same_campaign

  scope :active, -> { where(active: true) }
  scope :ongoing, -> { where.not(started_at: nil).where(ended_at: nil) }
  scope :current, -> { ongoing.order(started_at: :desc).first }

  SORT_ORDER = ["Uber-Boss", "Boss", "PC", "Ally", "Featured Foe", "Mook"]
  DEFAULT_SHOT_COUNT = 3

  def as_v1_json(args={})
    {
      id: id,
      name: name,
      description: description,
      gamemaster: campaign.user,
      active: active,
      at_a_glance: at_a_glance,
      created_at: created_at,
      updated_at: updated_at,
      shot_order: shot_order,
      sequence: sequence,
      effects: effects,
      character_effects: character_effects.where("character_effects.character_id IS NOT NULL").group_by { |ce| ce.shot_id },
      vehicle_effects: character_effects.where("character_effects.vehicle_id IS NOT NULL").group_by { |ce| ce.shot_id },
      image_url: image_url
    }
  end

  def current_shot
    shots.maximum(:shot) || 0
  end

  #    return fight.effects.filter((effect: Effect) => {
  #     return shot > 0 && (
  #       (fight.sequence == effect.start_sequence && shot <= effect.start_shot) ||
  #         (fight.sequence == effect.end_sequence && shot > effect.end_shot)
  #     )
  def active_effects
    @current_shot = current_shot
    @active_effects ||= effects.order(:severity).select do |effect|
      @current_shot > 0 &&
        (
          (sequence == effect.start_sequence && current_shot <= effect.start_shot) ||
          (sequence == effect.end_sequence && current_shot > effect.end_shot)
        )
    end
  end

  def shot_order
    shots
      .group_by { |sh| sh.shot }
      .sort_by { |shot, _shot_chars| shot.nil? ? 1000 : -shot.to_i }
      .map { |shot, shot_chars|
        [shot, shot_chars
          .sort_by(&:sort_order)
          .map(&:as_v1_json)
          .flatten
          .compact
        ]
      }.reject { |shot, shot_chars| shot_chars.empty? }
  end

  def ongoing?
    started_at.present? && ended_at.nil?
  end

  def ended?
    ended_at.present?
  end

  def can_modify?
    !ended?
  end

  # Custom getter to return all character IDs including duplicates
  def character_ids
    shots.pluck(:character_id).compact
  end

  # Custom setter to handle duplicate character IDs for mooks and featured foes
  def character_ids=(ids)
    return unless ids

    # Get current character IDs in the fight
    existing_character_ids = shots.pluck(:character_id).compact

    # Process new IDs
    ids_to_process = ids.map(&:to_s).compact

    # Find IDs to add and remove
    ids_to_add = ids_to_process - existing_character_ids
    ids_to_remove = existing_character_ids - ids_to_process

    # Handle duplicates - check if any IDs appear multiple times
    duplicate_ids = ids_to_process.group_by { |id| id }.select { |_, v| v.size > 1 }.keys

    # For duplicate IDs, check if they're mooks or featured foes
    duplicate_ids.each do |char_id|
      character = campaign.characters.find_by(id: char_id)
      next unless character

      # Only allow duplicates for mooks and featured foes
      # Character type is stored in action_values["Type"]
      char_type = character.action_values["Type"]
      if char_type == "Mook" || char_type == "Featured Foe"
        # Count how many instances we need
        needed_count = ids_to_process.count(char_id)
        current_count = existing_character_ids.count(char_id)

        # Add additional shots for the extra instances
        (needed_count - current_count).times do
          shots.create!(character_id: char_id, shot: nil)
        end if needed_count > current_count

        # Remove extra shots if we have too many
        if needed_count < current_count
          excess_count = current_count - needed_count
          shots.where(character_id: char_id).limit(excess_count).destroy_all
        end
      end
    end

    # Add new characters (non-duplicates)
    ids_to_add.each do |char_id|
      shots.create!(character_id: char_id, shot: nil)
    end

    # Remove characters that are no longer in the list
    shots.where(character_id: ids_to_remove).destroy_all if ids_to_remove.any?
  end

  def end_fight!(notes: nil)
    return false if ended?
    
    transaction do
      update!(ended_at: Time.current)
      # Broadcast fight ended event
      broadcast_fight_ended
    end
    true
  end

  def broadcast_encounter_update!
    # Skip if broadcasts are disabled (during batched updates)
    if Thread.current[:disable_broadcasts]
      Rails.logger.info "🔄 WEBSOCKET: Broadcast disabled (batched update in progress), skipping broadcast_encounter_update!"
      return
    end
    
    Rails.logger.info "🔄 WEBSOCKET: broadcast_encounter_update! called for fight #{id}"
    if started_at? && ended_at.nil?
      Rails.logger.info "🔄 WEBSOCKET: Fight is active, enqueuing BroadcastEncounterUpdateJob"
      BroadcastEncounterUpdateJob.perform_later(id)
    else
      Rails.logger.info "🔄 WEBSOCKET: Fight is not active (started_at: #{started_at}, ended_at: #{ended_at}), skipping broadcast"
    end
  end

  private

  def enqueue_discord_notification
    discord_server_id = server_id || CurrentFight.get_server_id_for_fight(id)
    Rails.logger.info("DISCORD: Checking for Discord notification. fight_id: #{id}, server_id: #{discord_server_id}, fight_message_id: #{fight_message_id}, channel_id: #{channel_id}")
    return unless discord_server_id.present? && channel_id.present?
    Rails.logger.info("DISCORD: Enqueuing DiscordNotificationJob for fight_id: #{id}")
    DiscordNotificationJob.perform_later(id)
  end

  def broadcast_update
    # Skip if broadcasts are disabled (during batched updates)
    if Thread.current[:disable_broadcasts]
      Rails.logger.info "🔄 WEBSOCKET: Broadcast disabled (batched update in progress), skipping broadcast_update"
      return
    end
    
    channel = "fight_#{id}"
    payload = { fight: :updated }
    Rails.logger.info "Broadcasting to #{channel} with payload: #{payload.inspect}"
    result = ActionCable.server.broadcast(channel, payload)
    Rails.logger.info "Broadcast result: #{result.inspect} (number of subscribers)"
  end

  def broadcast_fight_ended
    channel = "campaign_#{campaign_id}"
    payload = { 
      type: 'fight_ended',
      fight_id: id,
      fight_name: name
    }
    Rails.logger.info "Broadcasting fight ended to #{channel}"
    ActionCable.server.broadcast(channel, payload)
    
    # Also broadcast to fight channel
    fight_channel = "fight_#{id}"
    ActionCable.server.broadcast(fight_channel, { fight: :ended })
  end

  private

  def associations_belong_to_same_campaign
    return unless campaign_id.present?

    # Check characters through shots
    if characters.any? && characters.exists?(["campaign_id != ?", campaign_id])
      errors.add(:characters, "must all belong to the same campaign")
    end

    # Check vehicles through shots
    if vehicles.any? && vehicles.exists?(["campaign_id != ?", campaign_id])
      errors.add(:vehicles, "must all belong to the same campaign")
    end
  end
end
