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
    "Archetype" => ""
  }
  CHARACTER_TYPES=[
    "PC",
    "Ally",
    "Mook",
    "Featured Foe",
    "Boss",
    "Uber-Boss"
  ]

  has_many :fight_characters, dependent: :destroy
  has_many :fights, through: :fight_characters
  belongs_to :user, optional: true

  before_save :ensure_default_action_values
  before_save :ensure_integer_values
  before_save :ensure_non_integer_values

  def act!(fight:, shot_cost: Fight::DEFAULT_SHOT_COUNT)
    self.current_shot ||= 0
    self.current_shot -= shot_cost.to_i
    save!
  end

  def as_json(args=nil)
    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at,
      user: user,
      action_values: action_values,
      color: color,
      impairments: impairments,
      category: "character"
    }
  end

  def sort_order
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Speed", 0).to_i - impairments.to_i
    [1, Fight::SORT_ORDER.index(character_type), speed * -1, name]
  end

  private

  def ensure_default_action_values
    self.action_values ||= {}
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
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
