class Shot < ApplicationRecord
  belongs_to :fight
  belongs_to :location, optional: true, dependent: :destroy
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :driver_shot, optional: true, class_name: "Shot", foreign_key: "driver_id"
  belongs_to :driving_shot, optional: true, class_name: "Shot", foreign_key: "driving_id"
  has_many :character_effects, dependent: :destroy

  before_destroy :unlink_driver
  before_destroy :unlink_vehicle

  validate :ensure_campaign

  def as_json(args={})
    if driving_shot.present?
      # If the character is driving a vehicle, show them both
      [character.as_json(args.merge(shot: self)), driving.as_json(args.merge(shot: driving_shot))]
    elsif character.present?
      # A character is not driving a vehicle, so just show the character
      character.as_json(args.merge(shot: self))
    elsif driver_shot.blank? && vehicle.present?
      # A vehicle is not being driven, so just show the vehicle
      vehicle.as_json(args.merge(shot: self))
    end
  end

  def sort_order
    character&.sort_order(id) || vehicle&.sort_order(id)
  end

  def driver
    driver_shot&.character
  end

  def driving
    driving_shot&.vehicle
  end

  def act!(shot_cost: Fight::DEFAULT_SHOT_COUNT)
    self.shot ||= 0
    self.shot -= shot_cost.to_i
    save!
  end

  # must have a character or a vehicle
  validates :character, presence: true, if: -> { vehicle.nil? }
  validates :vehicle, presence: true, if: -> { character.nil? }

  private

  # When deleting a shot which contains a vehicle, we need to find the
  # other shot with this id as the `driving_id` and set them to
  # nil.
  def unlink_driver
    return unless vehicle_id

    fight.shots.where(driving_id: id).update_all(driving_id: nil)
  end

  # When deleting a shot which contains a character, we need to find the
  # other shot with this id as the `driver_id` and set them to
  # nil.
  def unlink_vehicle
    return unless character_id

    fight.shots.where(driver_id: id).update_all(driver_id: nil)
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
