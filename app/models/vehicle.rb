class Vehicle < ApplicationRecord
  has_many :fight_characters, dependent: :destroy
  has_many :fights, through: :fight_characters
  belongs_to :user, optional: true

  DEFAULT_ACTION_VALUES = {
    "Acceleration" => 0,
    "Handling" => 0,
    "Squeal" => 0,
    "Frame" => 0,
    "Crunch" => 0,
    "Condition Points" => 0,
    "Chase Points" => 0,
    "Pursuer" => true,
    "Position" => "Far",
    "Type" => "PC"
  }

  POSITIONS = ["Near", "Far"]

  before_save :ensure_default_action_values
  before_save :ensure_integer_values
  before_save :ensure_non_integer_values

  def sort_order
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Acceleration", 0).to_i - impairments.to_i
    [1, Fight::SORT_ORDER.index(character_type), speed * -1, name]
  end

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
      category: "vehicle"
    }
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
