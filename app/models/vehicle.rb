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

  has_one_attached :image
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

  after_update :broadcast_campaign_update

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
      impairments: impairments,
      category: "vehicle",
      count: shot&.count,
      shot_id: shot&.id,
      location: shot&.location,
      driver: driver_json(shot&.driver_shot),
      image_url: image_url,
      task: task
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

  def image_url
    return unless image_attachment && image_attachment.blob
    if Rails.env.production?
      image.attached? ? image.url : nil
    else
      Rails.application.routes.url_helpers.rails_blob_url(image_attachment.blob, only_path: true)
    end
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

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = {
      vehicle: VehicleSerializer.new(self).as_json,
    }
    result = ActionCable.server.broadcast(channel, payload)
    result = ActionCable.server.broadcast(channel, { vehicles: "reload" })
  end
end
