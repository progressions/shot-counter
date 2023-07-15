class Vehicle < ApplicationRecord
  DEFAULT_ACTION_VALUES = {
    "Acceleration" => 0,
    "Handling" => 0,
    "Squeal" => 0,
    "Frame" => 0,
    "Crunch" => 0,
    "Condition Points" => 0,
    "Chase Points" => 0,
    "Pursuer" => "true",
    "Position" => "far",
    "Type" => "PC",
  }

  has_many :shots, dependent: :destroy
  has_many :fights, through: :shots
  belongs_to :user, optional: true
  belongs_to :campaign
  belongs_to :faction, optional: true
  has_many :character_effects
  has_many :memberships
  has_many :parties, through: :memberships

  POSITIONS = %w(near far)

  before_validation :ensure_default_action_values
  before_validation :ensure_integer_values
  before_validation :ensure_non_integer_values

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  def as_json(args={})
    {
      id: id,
      name: name,
      active: active,
      created_at: created_at,
      faction_id: faction_id,
      faction: { name: faction&.name },
      updated_at: updated_at,
      user: user,
      action_values: action_values,
      color: args[:color] || color,
      impairments: impairments,
      category: "vehicle",
      count: args[:count],
      shot_id: args[:shot_id],
    }
  end

  scope :active, -> { where(active: true) }

  scope :by_type, -> (player_type) do
    where("action_values->>'Type' IN (?)", player_type)
  end

  def sort_order(shot_id=nil)
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Acceleration", 0).to_i - impairments.to_i
    [1, Fight::SORT_ORDER.index(character_type), speed * -1, name, shot_id].compact
  end

  def good_guy?
    action_values.fetch("Type") == "PC" || action_values.fetch("Type") == "Ally"
  end

  def bad_guy?
    !good_guy?
  end

  def category
    "vehicle"
  end

  def effects_for_fight(fight)
    shots
      .find_by(fight_id: fight.id)
      .character_effects
  end

  private

  def ensure_default_action_values
    self.action_values ||= {}
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
  end

  def validate_position
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
    unless POSITIONS.include?(self.action_values["Position"])
      errors.add(:base, "Position must be one of #{POSITIONS.join(', ')}")
    end
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
