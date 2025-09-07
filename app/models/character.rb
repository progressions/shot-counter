class Character < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include OnboardingTrackable
  include CacheVersionable

  DEFAULT_ACTION_VALUES = {
    "Guns" => 0,
    "Martial Arts" => 0,
    "Sorcery" => 0,
    "Scroungetech" => 0,
    "Genome" => 0,
    "Mutant" => 0,
    "Creature" => 0,
    "Defense" => 0,
    "Toughness" => 0,
    "Speed" => 0,
    "Fortune" => 0,
    "Max Fortune" => 0,
    "FortuneType" => "Fortune",
    "MainAttack" => "Guns",
    "SecondaryAttack" => nil,
    "Wounds" => 0,
    "Type" => "PC",
    "Marks of Death" => 0,
    "Archetype" => "",
    "Damage" => 0,
  }
  CHARACTER_TYPES=[
    "PC",
    "Ally",
    "Mook",
    "Featured Foe",
    "Boss",
    "Uber-Boss"
  ]
  DEFAULT_DESCRIPTION = {
    "Nicknames" => "",
    "Age" => "",
    "Height" => "",
    "Weight" => "",
    "Hair Color" => "",
    "Eye Color" => "",
    "Style of Dress" => "",
    "Appearance" => "",
    "Background" => "",
    "Melodramatic Hook" => "",
  }
  DEFAULT_SKILLS = {
    "Deceit" => 0,
    "Detective" => 0,
    "Driving" => 0,
    "Fix-It" => 0,
    "Gambling" => 0,
    "Intimidation" => 0,
    "Intrusion" => 0,
    "Leadership" => 0,
    "Medicine" => 0,
    "Police" => 0,
    "Sabotage" => 0,
    "Seduction" => 0,
    "Constituion" => 0,
    "Will" => 0,
    "Notice" => 0,
    "Strength" => 0
  }

  has_one_attached :image
  has_many :shots, dependent: :destroy
  has_many :fights, through: :shots
  belongs_to :faction, optional: true
  belongs_to :user, optional: true
  belongs_to :campaign
  belongs_to :juncture, optional: true
  has_many :character_effects
  has_many :character_schticks, dependent: :destroy
  has_many :schticks, through: :character_schticks
  has_many :advancements
  has_many :carries
  has_many :weapons, through: :carries
  has_many :memberships
  has_many :parties, through: :memberships
  has_many :attunements
  has_many :sites, through: :attunements
  has_many :image_positions, as: :positionable, dependent: :destroy

  accepts_nested_attributes_for :faction

  before_save :ensure_default_action_values
  before_save :ensure_default_description
  before_save :ensure_default_skills
  before_save :ensure_integer_action_values
  before_save :ensure_integer_skills
  before_save :ensure_non_integer_action_values

  after_update :broadcast_encounter_update

  validates :name, presence: true, uniqueness: { scope: :campaign_id, message: "has already been taken" }
  validates :impairments, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :new_owner_is_campaign_member, on: :update, if: :user_id_changed?
  validate :associations_belong_to_same_campaign
  validate :valid_status_array

  scope :active, -> { where(active: true) }
  scope :requiring_up_check, -> { where("status @> ?", '["up_check_required"]') }
  scope :out_of_fight, -> { where("status @> ?", '["out_of_fight"]') }
  scope :in_fight, -> { where.not("status @> ?", '["out_of_fight"]') }

  scope :by_type, -> (player_type) do
    where("action_values->>'Type' IN (?)", player_type)
  end

  attr_accessor :attaching_image

  def broadcast_encounter_update
    # Skip if broadcasts are disabled (during batched updates)
    return if Thread.current[:disable_broadcasts]
    
    fights.each(&:broadcast_encounter_update!)
  end

  def as_v1_json(args={})
    shot = args[:shot]
    {
      id: id,
      name: name,
      active: active,
      created_at: created_at,
      updated_at: updated_at,
      user: user,
      action_values: is_pc? ? action_values : action_values.merge("Wounds" => shot&.count),
      faction_id: faction_id,
      faction: {
        id: faction&.id,
        name: faction&.name,
      },
      description: description,
      schticks: schticks.order(:category, :path, :name),
      skills: skills.sort_by { |key, value| [(DEFAULT_SKILLS.keys.include?(key) ? 0 : 1), key] }.to_h,
      advancements: advancements.order(:created_at),
      sites: sites.order(:created_at).map { |site|
        {
          id: site.id,
          name: site.name,
          image_url: site.image_url
        }
      },
      weapons: weapons,
      category: "character",
      image_url: image_url,
      task: task,
      notion_page_id: notion_page_id,

      impairments: is_pc? ? impairments : shot&.impairments,
      count: shot&.count,
      color: shot&.color || color,
      location: shot&.location,
      shot_id: shot&.id,
      action_items: shot&.action_items || {},

      driving: driving_json(shot),
      wealth: wealth,
      juncture_id: juncture_id,
      juncture: {
        id: juncture&.id,
        name: juncture&.name,
      }
    }
  end

  def highest_schticks
    schticks.order(:category, :path, :name)
  end

  def driving_json(vehicle_shot)
    return {} unless vehicle_shot

    vehicle = vehicle_shot&.driving

    return {} unless vehicle

    {
      shot_id: vehicle_shot&.id,
      id: vehicle.id,
      name: vehicle.name,
      shot_id: vehicle_shot&.id,
      action_values: vehicle.action_values.slice("Acceleration"),
    }
  end

  def as_notion(args={})
    values = {
      "Name" => { "title"=>[{"text"=>{"content"=> self.name}}] },
      "Enemy Type" => { "select"=>{"name"=> self.action_values.fetch("Type")} },
      "Wounds" => { "number" => self.action_values.fetch("Wounds", nil) },
      "Defense" => { "number" => self.action_values.fetch("Defense", nil) },
      "Toughness" => { "number" => self.action_values.fetch("Toughness", nil) },
      "Speed" => { "number" => self.action_values.fetch("Speed", nil) },
      "Fortune" => { "number" => self.action_values.fetch("Max Fortune", nil) },
      "Guns" => { "number" => self.action_values.fetch("Guns", nil) },
      "Martial Arts" => { "number" => self.action_values.fetch("Martial Arts", nil) },
      "Sorcery" => { "number" => self.action_values.fetch("Sorcery", nil) },
      "Mutant" => { "number" => self.action_values.fetch("Mutant", nil) },
      "Scroungetech" => { "number" => self.action_values.fetch("Scroungetech", nil) },
      "Creature" => { "number" => self.action_values.fetch("Creature", nil) },
      "Damage" => {
        "rich_text" => [{"text" => { "content" => self.action_values.fetch("Damage", "").to_s} }]
      },
      "Inactive" => { "checkbox"=> !self.active },
      "Tags" => { "multi_select" => tags_for_notion },
      "Age" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Age", "").to_s} }]
      },
      "Nicknames" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Nicknames", "").to_s} }]
      },
      "Height" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Height", "").to_s} }]
      },
      "Weight" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Weight", "").to_s} }]
      },
      "Hair Color" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Hair Color", "").to_s} }]
      },
      "Eye Color" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Eye Color", "").to_s} }]
      },
      "Style of Dress" => {
        "rich_text" => [{"text" => { "content" => self.description.fetch("Style of Dress", "").to_s} }]
      },
      "Melodramatic Hook" => {
        "rich_text" => [{"text" => { "content" => FightPoster.strip_html_p_to_br(self.description.fetch("Melodramatic Hook", "").to_s) } }]
      },
      "Description" => {
        "rich_text" => [{"text" => { "content" => FightPoster.strip_html_p_to_br(self.description.fetch("Appearance", "").to_s)} }]
      },
    }

    if Rails.env.production?
      protocol = Rails.configuration.action_mailer.default_url_options[:protocol]
      host = Rails.configuration.action_mailer.default_url_options[:host]
      url = "#{protocol}://#{host}/characters/#{self.id}"
      values["Chi War Link"] = { "url" => url }
    end

    if self.action_values["MainAttack"].present?
      values["MainAttack"] = {
        "select"=>{"name"=>self.action_values.fetch("MainAttack", "")}
      }
    end
    if self.action_values["SecondaryAttack"].present?
      values["SecondaryAttack"] = {
        "select"=>{"name"=>self.action_values.fetch("SecondaryAttack", "")}
      }
    end
    if self.action_values["FortuneType"].present?
      values["FortuneType"] = {
        "select"=>{"name"=>self.action_values.fetch("FortuneType", "")}
      }
    end
    if self.action_values["Archetype"].present?
      values["Type"] = {
        "rich_text" => [{"text" => { "content" => self.action_values.fetch("Archetype", "")} }]
      }
    end
    if self.faction.present?
      values["Faction Tag"] = { "multi_select" => [{ "name" => self.faction.name }] }
    end
    values
  end

  def tags_for_notion
    tags = []
    if self.action_values.dig("Type") != "PC"
      tags << { "name" => "NPC" }
    end
    if self.action_values["Type"].present?
      tags << { "name" => self.action_values.fetch("Type") }
    end
    if self.faction.present?
      tags << { "name" => self.faction.name }
    end
    tags.compact
  end

  def attributes_from_notion(page)
    av = {
      "Archetype" => page.dig("properties", "Type", "rich_text", 0, "text", "content"),
      "Type" => page.dig("properties", "Enemy Type", "select", "name"),
      "MainAttack" => page.dig("properties", "MainAttack", "select", "name"),
      "SecondaryAttack" => page.dig("properties", "SecondaryAttack", "select", "name"),
      "FortuneType" => page.dig("properties", "FortuneType", "select", "name"),

      "Wounds" => av_or_new("Wounds", page.dig("properties", "Wounds", "number")),
      "Defense" => av_or_new("Defense", page.dig("properties", "Defense", "number")),
      "Toughness" => av_or_new("Toughness", page.dig("properties", "Toughness", "number")),
      "Speed" => av_or_new("Speed", page.dig("properties", "Speed", "number")),
      "Guns" => av_or_new("Guns", page.dig("properties", "Guns", "number")),
      "Martial Arts" => av_or_new("Martial Arts", page.dig("properties", "Martial Arts", "number")),
      "Sorcery" => av_or_new("Sorcery", page.dig("properties", "Sorcery", "number")),
      "Creature" => av_or_new("Creature", page.dig("properties", "Creature", "number")),
      "Scroungetech" => av_or_new("Scroungetech", page.dig("properties", "Scroungetech", "number")),
      "Mutant" => av_or_new("Mutant", page.dig("properties", "Mutant", "number")),
    }
    description = {
      "Age" => page.dig("properties", "Age", "rich_text", 0, "text", "content"),
      "Height" => page.dig("properties", "Height", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
      "Weight" => page.dig("properties", "Weight", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
      "Eye Color" => page.dig("properties", "Eye Color", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
      "Hair Color" => page.dig("properties", "Hair Color", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
      "Appearance" => page.dig("properties", "Description", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
      "Style of Dress" => page.dig("properties", "Style of Dress", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
      "Melodramatic Hook" => page.dig("properties", "Melodramatic Hook", "rich_text").map { |rt| rt.dig("plain_text") }.join(""),
    }
    self.attributes.symbolize_keys.merge({
      notion_page_id: page["id"],
      name: page.dig("properties", "Name", "title")&.first&.dig("plain_text"),
      action_values: self.action_values.merge(av),
      description: self.description.merge(description),
    })
  end

  def av_or_new(key, new_value=nil)
    if self.action_values[key].to_s.to_i == self.action_values[key]
      return self.action_values[key].to_i > 7 ? self.action_values[key] : new_value
    end
    self.action_values[key] ? self.action_values[key] : new_value
  end

  def primary_attack
    main = action_values.fetch("MainAttack")
    action_values.fetch(main)
  end

  def category
    "character"
  end

  def sort_order(shot_id=nil)
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Speed", 0).to_i - impairments.to_i
    [0, Fight::SORT_ORDER.index(character_type), speed * -1, name.downcase, shot_id].compact
  end

  def is_pc?
    action_values.fetch("Type") == "PC"
  end

  def good_guy?
    action_values.fetch("Type") == "PC" || action_values.fetch("Type") == "Ally"
  end

  def bad_guy?
    !good_guy?
  end

  # Alias for consistency with test naming
  def pc?
    is_pc?
  end

  # Status helper methods
  def up_check_required?
    status&.include?("up_check_required") || false
  end

  def out_of_fight?
    status&.include?("out_of_fight") || false
  end

  def add_status(new_status)
    current_status = status || []
    self.status = (current_status + [new_status]).uniq
  end

  def remove_status(status_to_remove)
    current_status = status || []
    self.status = current_status - [status_to_remove]
  end

  def clear_status
    self.status = []
  end

  def increment_marks_of_death
    marks = action_values["Marks of Death"] || 0
    action_values["Marks of Death"] = marks + 1
    save
  end

  def effects_for_fight(fight)
    shots
      .find_by(fight_id: fight.id)
      .character_effects
  end

  def main_attack
    action_values.fetch("MainAttack")
  end

  def secondary_attack
    action_values.fetch("SecondaryAttack")
  end

  def fortune_type
    action_values.fetch("FortuneType")
  end

  def sync_to_notion
    return unless notion_page_id.present?

    if NotionService.update_notion_from_character(self)
      update(last_synced_to_notion_at: Time.current)
    end
  end

  private

  def attaching_image?
    attaching_image
  end

  def ensure_default_action_values
    self.action_values ||= {}
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
  end

  def ensure_default_description
    self.description ||= {}
    self.description = DEFAULT_DESCRIPTION.merge(self.description)
  end

  def ensure_default_skills
    self.skills ||= {}
    self.skills = DEFAULT_SKILLS.merge(self.skills)
  end

  def ensure_integer_skills
    skills.each do |key, value|
      self.skills[key] = self.skills[key].to_i
    end
  end

  def ensure_integer_action_values
    DEFAULT_ACTION_VALUES.select do |key, value|
      value == 0
    end.each do |key, value|
      self.action_values[key] = self.action_values[key].to_i
    end
  end

  def ensure_non_integer_action_values
    DEFAULT_ACTION_VALUES.reject do |key, value|
      value == 0
    end.each do |key, value|
      if self.action_values[key] == 0
        self.action_values[key] = DEFAULT_ACTION_VALUES[key]
      end
    end
  end
  
  private
  
  def new_owner_is_campaign_member
    # Only validate if user_id actually changed to a different value
    return unless campaign.present? && user.present? && user_id_changed? && user_id_was != user_id
    
    # Allow gamemaster to own characters even if not a member
    return if campaign.user_id == user_id
    
    unless campaign.users.include?(user)
      errors.add(:user_id, "must be a member of the campaign")
    end
  end

  def validate_marks_of_death
    marks = action_values["Marks of Death"]
    return if marks.nil?
    
    marks_value = marks.to_i
    if marks_value < 0 || marks_value > 5
      errors.add(:base, "Marks of Death must be between 0 and 5")
    end
  end

  def valid_status_array
    return if status.is_a?(Array)
    errors.add(:status, "must be an array")
  end

  def associations_belong_to_same_campaign
    return unless campaign_id.present?

    # Check faction
    if faction_id.present? && faction && faction.campaign_id != campaign_id
      errors.add(:faction, "must belong to the same campaign")
    end

    # Check juncture
    if juncture_id.present? && juncture && juncture.campaign_id != campaign_id
      errors.add(:juncture, "must belong to the same campaign")
    end

    # Check schticks
    if schticks.any? && schticks.exists?(["campaign_id != ?", campaign_id])
      errors.add(:schticks, "must all belong to the same campaign")
    end

    # Check weapons
    if weapons.any? && weapons.exists?(["campaign_id != ?", campaign_id])
      errors.add(:weapons, "must all belong to the same campaign")
    end

    # Check parties
    if parties.any? && parties.exists?(["campaign_id != ?", campaign_id])
      errors.add(:parties, "must all belong to the same campaign")
    end

    # Check sites
    if sites.any? && sites.exists?(["campaign_id != ?", campaign_id])
      errors.add(:sites, "must all belong to the same campaign")
    end

    # Check fights (through shots)
    if fights.any? && fights.exists?(["campaign_id != ?", campaign_id])
      errors.add(:fights, "must all belong to the same campaign")
    end
  end
end
