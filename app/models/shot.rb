class Shot < ApplicationRecord
  belongs_to :fight
  belongs_to :location, optional: true, dependent: :destroy
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :driver, optional: true, class_name: "Character", foreign_key: "driver_id"
  belongs_to :driving, optional: true, class_name: "Vehicle", foreign_key: "driving_id"
  has_many :character_effects, dependent: :destroy

  before_destroy :unlink_driver
  before_destroy :unlink_vehicle

  validate :ensure_campaign

  def act!(shot_cost: Fight::DEFAULT_SHOT_COUNT)
    self.shot ||= 0
    self.shot -= shot_cost.to_i
    save!
  end

  # must have a character or a vehicle
  validates :character, presence: true, if: -> { vehicle.nil? }
  validates :vehicle, presence: true, if: -> { character.nil? }

  private

  def unlink_driver
    return unless driving_id

    fight.shots.where(driving_id: driving_id).update_all(driving_id: nil)
  end

  def unlink_vehicle
    fight.shots.where(driver_id: character_id).update_all(driver_id: nil)
  end

  def ensure_campaign
    if (self.character && self.character.campaign != self.fight.campaign)
      errors.add(:character, "must belong to the same campaign as its fight")
    end
    if (self.vehicle && self.vehicle.campaign != self.fight.campaign)
      errors.add(:vehicle, "must belong to the same campaign as its fight")
    end
  end
end
