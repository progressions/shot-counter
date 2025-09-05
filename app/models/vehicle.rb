class Vehicle < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include CacheVersionable

  DEFAULT_ACTION_VALUES = {
    "Acceleration" => 0,
    "Handling" => 0,
    "Squeal" => 0,
    "Frame" => 0,
    "Crunch" => 0,
    "Condition Points" => 0,
    "Chase Points" => 0,
    "Pursuer" => "true",
    "Type" => "PC",
    "Archetype" => "Car",
  }
  DEFAULT_DESCRIPTION = {
    "Size" => "",
    "Weight" => "",
    "Color" => "",
    "Appearance" => "",
  }

  has_one_attached :image
  has_many :shots, dependent: :destroy
  has_many :fights, through: :shots
  belongs_to :user, optional: true
  belongs_to :campaign
  belongs_to :faction, optional: true
  belongs_to :juncture, optional: true
  has_many :character_effects
  has_many :memberships
  has_many :parties, through: :memberships
  has_many :image_positions, as: :positionable, dependent: :destroy
  
  # Chase relationships
  has_many :pursuer_relationships, class_name: 'ChaseRelationship', foreign_key: 'pursuer_id', dependent: :destroy
  has_many :evader_relationships, class_name: 'ChaseRelationship', foreign_key: 'evader_id', dependent: :destroy

  before_validation :ensure_default_description
  before_validation :ensure_default_action_values
  before_validation :ensure_integer_values
  before_validation :ensure_non_integer_values

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validate :associations_belong_to_same_campaign

  def as_v1_json(args={})
    shot = args[:shot]
    {
      id: id,
      name: name,
      active: active,
      created_at: created_at,
      faction_id: faction_id,
      faction: { name: faction&.name },
      updated_at: updated_at,
      user: user,
      action_values: action_values.merge({
        "Type" => vehicle_type(shot&.driver),
      }),
      color: shot&.color || color,
      impairments: shot&.impairments || impairments,  # Use shot's impairments if available
      category: "vehicle",
      count: shot&.count,
      shot_id: shot&.id,
      location: shot&.location,
      driver: driver_json(shot&.driver_shot),
      image_url: image_url,
      task: task,
      # Add defeat-related fields
      was_rammed_or_damaged: shot&.was_rammed_or_damaged || false,
      is_defeated_in_chase: defeated_in_chase?(shot),
      defeat_type: defeat_type(shot),
      defeat_threshold: defeat_threshold(shot)
    }
  end

  def vehicle_type(driver)
    return action_values.fetch("Type") unless driver

    driver
      .action_values
      .fetch("Type", "Featured Foe")
  end

  def driver_json(driver_shot)
    return {} unless driver_shot

    driver = driver_shot.character

    return {} unless driver

    {
      shot_id: driver_shot.id,
      id: driver.id,
      name: driver.name,
      skills: driver.skills.slice("Driving"),
      action_values: driver.action_values.merge({
        "Type" => driver.action_values.fetch("Type", "Featured Foe"),
      }),
    }
  end

  scope :active, -> { where(active: true) }

  scope :by_type, -> (player_type) do
    where("vehicles.action_values->>'Type' IN (?)", player_type)
  end

  def sort_order(shot_id=nil)
    character_type = action_values.fetch("Type")
    speed = action_values.fetch("Acceleration", 0).to_i - impairments.to_i
    [1, Fight::SORT_ORDER.index(character_type), speed * -1, name.downcase, shot_id].compact
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

  # Get position relative to another vehicle in a fight
  def position_relative_to(other_vehicle, fight)
    # Check if this vehicle is pursuing the other
    relationship = ChaseRelationship.active
      .find_by(pursuer: self, evader: other_vehicle, fight: fight)
    
    # If not, check if the other is pursuing this vehicle
    relationship ||= ChaseRelationship.active
      .find_by(pursuer: other_vehicle, evader: self, fight: fight)
    
    relationship&.position
  end

  # Get all active chase relationships for this vehicle in a fight
  def chase_relationships_in_fight(fight)
    ChaseRelationship.active
      .where(fight: fight)
      .where('pursuer_id = ? OR evader_id = ?', id, id)
  end

  # Check if this vehicle is pursuing another in a fight
  def pursuing?(other_vehicle, fight)
    ChaseRelationship.active
      .exists?(pursuer: self, evader: other_vehicle, fight: fight)
  end

  # Check if this vehicle is being pursued by another in a fight
  def pursued_by?(other_vehicle, fight)
    ChaseRelationship.active
      .exists?(pursuer: other_vehicle, evader: self, fight: fight)
  end

  # Vehicle defeat detection methods
  def defeated_in_chase?(shot = nil)
    chase_points = action_values.fetch("Chase Points", 0).to_i
    chase_points >= defeat_threshold(shot)
  end

  def defeat_threshold(shot = nil)
    # Get driver type, either from shot's driver or from vehicle's own type
    driver_type = if shot&.driver_shot&.character
      shot.driver_shot.character.action_values.fetch("Type", "Featured Foe")
    else
      vehicle_type(nil)
    end

    # Map driver type to defeat threshold based on wound thresholds
    case driver_type
    when "Boss", "Uber-Boss"
      50
    else # PC, Ally, Featured Foe, etc.
      35
    end
  end

  def defeat_type(shot)
    return nil unless defeated_in_chase?(shot)
    
    # Check if vehicle was rammed or damaged
    if shot&.was_rammed_or_damaged
      "crashed"
    else
      "boxed_in"
    end
  end

  private

  def ensure_default_action_values
    self.action_values ||= {}
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
  end

  def ensure_default_description
    self.description ||= {}
    self.description = DEFAULT_DESCRIPTION.merge(self.description)
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

    # Check parties
    if parties.any? && parties.exists?(["campaign_id != ?", campaign_id])
      errors.add(:parties, "must all belong to the same campaign")
    end

    # Check fights (through shots)
    if fights.any? && fights.exists?(["campaign_id != ?", campaign_id])
      errors.add(:fights, "must all belong to the same campaign")
    end
  end
end
