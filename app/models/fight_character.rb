class FightCharacter < ApplicationRecord
  belongs_to :fight
  belongs_to :character

  def act!(shot_cost: DEFAULT_SHOT_COUNT)
    self.shot ||= 0
    self.shot -= shot_cost.to_i
    save!
  end
end
