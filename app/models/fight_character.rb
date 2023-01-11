class FightCharacter < ApplicationRecord
  belongs_to :fight
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true

  def act!(shot_cost: Fight::DEFAULT_SHOT_COUNT)
    self.shot ||= 0
    self.shot -= shot_cost.to_i
    save!
  end
end
