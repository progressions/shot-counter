class Shot < ApplicationRecord
  belongs_to :fight, touch: true
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :driver_shot, optional: true, class_name: "Shot", foreign_key: "driver_id"
  belongs_to :driving_shot, optional: true, class_name: "Shot", foreign_key: "driving_id"
  has_many :character_effects, dependent: :destroy

  after_update :broadcast_encounter_update
  before_destroy :unlink_driver
  before_destroy :unlink_vehicle

  validate :ensure_campaign

  def broadcast_encounter_update
    # Skip if broadcasts are disabled (during batched updates)
    return if Thread.current[:disable_broadcasts]
    
    fight.broadcast_encounter_update!
  end

  def as_v1_json(args={})
    if driving_shot.present?
      # If the character is driving a vehicle, show them both. Send the vehicle's
      # shot to its JSON method, so it includes the correct shot_id.
      [
        character.as_v1_json(args.merge(shot: self, action_items: action_items)),
        driving.as_v1_json(args.merge(shot: driving_shot))
      ]
    elsif character.present?
      # A character is not driving a vehicle, so just show the character
      character.as_v1_json(args.merge(shot: self, action_items: action_items))
    elsif driver_shot.blank? && vehicle.present?
      # A vehicle is not being driven, so just show the vehicle
      vehicle.as_v1_json(args.merge(shot: self))
    end
  end

  def action_items
    {
      reload_check: true,
      up_check: true
    }
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
