class Character < ApplicationRecord
  DEFAULT_SHOT_COUNT = 3
  DEFAULT_ACTION_VALUES = {
    "Guns" => nil,
    "Martial Arts" => nil,
    "Sorcery" => nil,
    "Scroungetech" => nil,
    "Genome" => nil,
    "Defense" => nil,
    "Toughness" => nil,
    "Speed" => nil,
    "Fortune" => nil,
    "Max Fortune" => nil,
    "FortuneType" => "Fortune",
    "MainAttack" => "Guns",
    "SecondaryAttack" => "Martial Arts",
    "Wounds" => 0,
    "Type" => ""
  }
  CHARACTER_TYPES=[
    "PC",
    "Ally",
    "Mook",
    "Featured Foe",
    "Boss",
    "Uber-Boss"
  ]
  SORT_ORDER = ["Uber-Boss", "PC", "Boss", "Featured Foe", "Ally", "Mook"]

  has_many :fight_characters, dependent: :destroy
  has_many :fights, through: :fight_characters
  belongs_to :user, optional: true

  before_save :ensure_default_action_values

  def act!(fight:, shot_cost: DEFAULT_SHOT_COUNT)
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
    }
  end

  def sort_order
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Speed", 0).to_i - impairments.to_i
    [SORT_ORDER.index(character_type), speed * -1, name]
  end

  private

  def ensure_default_action_values
    self.action_values ||= {}
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
  end
end
