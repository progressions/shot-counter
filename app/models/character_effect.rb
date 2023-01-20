class CharacterEffect < ApplicationRecord
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :fight

  validate :character_belongs_to_fight
  validate :vehicle_belongs_to_fight
  validate :ensure_character_or_vehicle

  def as_json(args={})
    {
      id: id,
      title: title,
    }
  end

  private

  def ensure_character_or_vehicle
    if self.vehicle && self.character
      errors.add(:vehicle, "must not be present if character is set")
      errors.add(:character, "must not be present if vehicle is set")
      return
    end
    if !self.vehicle && !self.character
      errors.add(:vehicle, "must be present if character is not set")
      errors.add(:character, "must be present if vehicle is not set")
    end
  end

  def character_belongs_to_fight
    if self.fight_id && self.character_id && !fight.character_ids.include?(self.character_id)
      errors.add(:character, "must belong to the fight")
    end
  end

  def vehicle_belongs_to_fight
    if self.fight_id && self.vehicle_id && !fight.vehicle_ids.include?(self.vehicle_id)
      errors.add(:vehicle, "must belong to the fight")
    end
  end
end
