class CharacterEffect < ApplicationRecord
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :fight

  validate :character_belongs_to_fight
  validate :vehicle_belongs_to_fight
  validate :ensure_character_or_vehicle
  validate :ensure_action_value_and_change
  validate :ensure_valid_action_value

  def as_json(args={})
    {
      id: id,
      title: title,
      description: description,
      severity: severity,
      action_value: action_value,
      change: change
    }
  end

  private

  def ensure_valid_action_value
    if self.character_id && self.action_value && !Character::DEFAULT_ACTION_VALUES.keys.include?(self.action_value)
      errors.add(:action_value, "must be a valid key")
    end
    if self.vehicle_id && self.action_value && !Vehicle::DEFAULT_ACTION_VALUES.keys.include?(self.action_value)
      errors.add(:action_value, "must be a valid key")
    end
  end

  def ensure_action_value_and_change
    if !self.action_value && self.change
      errors.add(:action_value, "must be present if change is set")
    end
    if !self.change && self.action_value
      errors.add(:change, "must be present if action_value is set")
    end
  end

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
