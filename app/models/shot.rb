class Shot < ApplicationRecord
  belongs_to :fight
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  has_many :character_effects, dependent: :destroy
  has_many :locations, dependent: :destroy

  validate :ensure_campaign

  def act!(shot_cost: Fight::DEFAULT_SHOT_COUNT)
    self.shot ||= 0
    self.shot -= shot_cost.to_i
    save!
  end

  private

  def ensure_campaign
    if (self.character && self.character.campaign != self.fight.campaign)
      errors.add(:character, "must belong to the same campaign as its fight")
    end
    if (self.vehicle && self.vehicle.campaign != self.fight.campaign)
      errors.add(:vehicle, "must belong to the same campaign as its fight")
    end
  end
end
