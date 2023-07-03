class Character < ApplicationRecord
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
    "SecondaryAttack" => "Martial Arts",
    "Wounds" => 0,
    "Type" => "PC",
    "Marks of Death" => 0,
    "Archetype" => "",
    "Damage" => 0,
    "Faction" => ""
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

  has_many :fight_characters, dependent: :destroy
  has_many :fights, through: :fight_characters
  belongs_to :faction, optional: true
  belongs_to :user, optional: true
  belongs_to :campaign
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

  validates :name, presence: true, uniqueness: { scope: :campaign_id, message: "must be unique" }

  before_save :ensure_default_action_values
  before_save :ensure_default_description
  before_save :ensure_default_skills
  before_save :ensure_integer_values
  before_save :ensure_non_integer_values
  before_save :ensure_faction

  def act!(fight:, shot_cost: Fight::DEFAULT_SHOT_COUNT)
    self.current_shot ||= 0
    self.current_shot -= shot_cost.to_i
    save!
  end

  def as_json(args={})
    {
      id: id,
      name: name,
      active: active,
      created_at: created_at,
      updated_at: updated_at,
      user: user,
      action_values: action_values.merge("Faction" => faction&.name),
      faction: faction,
      description: description,
      schticks: schticks.includes(:prerequisite).order(:category, :path, :name),
      skills: skills.sort_by { |key, value| [(DEFAULT_SKILLS.keys.include?(key) ? 0 : 1), key] }.to_h,
      color: color,
      impairments: impairments,
      advancements: advancements.order(:created_at),
      sites: sites.order(:created_at),
      weapons: weapons,
      category: "character",
    }
  end

  def sort_order
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Speed", 0).to_i - impairments.to_i
    [0, Fight::SORT_ORDER.index(character_type), speed * -1, name]
  end

  def good_guy?
    action_values.fetch("Type") == "PC" || action_values.fetch("Type") == "Ally"
  end

  def bad_guy?
    !good_guy?
  end

  def effects_for_fight(fight)
    fight_characters
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

  private

  def validate_schticks
    self.schticks ||= []
    self.schticks.each do |schtick|
      if schtick[:name].blank?
        errors.add(:schticks, "must have a name")
      end
    end
  end

  def ensure_faction
    if action_values.fetch("Faction").present?
      self.faction = self.campaign.factions.find_or_create_by(name: action_values.fetch("Faction"))
    else
      self.faction = nil
    end
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

  def ensure_integer_values
    DEFAULT_ACTION_VALUES.select do |key, value|
      value == 0
    end.each do |key, value|
      self.action_values[key] = self.action_values[key].to_i
    end
  end

  def ensure_non_integer_values
    DEFAULT_ACTION_VALUES.reject do |key, value|
      value == 0
    end.each do |key, value|
      if self.action_values[key] == 0
        self.action_values[key] = DEFAULT_ACTION_VALUES[key]
      end
    end
  end
end
