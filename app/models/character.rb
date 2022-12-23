class Character < ApplicationRecord
  DEFAULT_SHOT_COUNT = 3

  belongs_to :fight

  def act!(shots=DEFAULT_SHOT_COUNT)
    self.current_shot ||= 0
    self.current_shot -= shots
    save!
  end
end
