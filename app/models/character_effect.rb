class CharacterEffect < ApplicationRecord
  belongs_to :character
  belongs_to :fight

  validate :character_belongs_to_fight

  def as_json(args={})
    {
      id: id,
      title: title,
    }
  end

  private

  def character_belongs_to_fight
    if self.fight_id && self.character_id && !fight.character_ids.include?(self.character_id)
      errors.add(:character, "must belong to the fight")
    end
  end
end
