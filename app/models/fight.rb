class Fight < ApplicationRecord
  include Broadcastable

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

  has_many :image_positions, as: :positionable, dependent: :destroy

  scope :active, -> { where(active: true) }

  SORT_ORDER = ["Uber-Boss", "Boss", "PC", "Featured Foe", "Ally", "Mook"]
  DEFAULT_SHOT_COUNT = 3

  def as_v1_json(args={})
    {
      id: id,
      name: name,
      description: description,
      gamemaster: campaign.user,
      active: active,
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

  def image_url
    image.attached? ? image.url : nil
  # rescue
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

  private

  def enqueue_discord_notification
    discord_server_id = server_id || CurrentFight.get_server_id_for_fight(id)
    Rails.logger.info("DISCORD: Checking for Discord notification. fight_id: #{id}, server_id: #{discord_server_id}, fight_message_id: #{fight_message_id}, channel_id: #{channel_id}")
    return unless discord_server_id.present? && channel_id.present?
    Rails.logger.info("DISCORD: Enqueuing DiscordNotificationJob for fight_id: #{id}")
    DiscordNotificationJob.perform_later(id)
  end

  def broadcast_update
    channel = "fight_#{id}"
    payload = { fight: :updated }
    Rails.logger.info "Broadcasting to #{channel} with payload: #{payload.inspect}"
    result = ActionCable.server.broadcast(channel, payload)
    Rails.logger.info "Broadcast result: #{result.inspect} (number of subscribers)"
  end
end
