class Character < ApplicationRecord
  DEFAULT_SHOT_COUNT = 3
  DEFAULT_ACTION_VALUES = {
    "Guns" => nil,
    "Martial Arts" => nil,
    "Sorcery" => nil,
    "Scroungetech" => nil,
    "Genome" => nil,
    "Defense" => 13,
    "Toughness" => 6,
    "Speed" => 6,
    "Fortune" => 6,
    "Max Fortune" => 6,
    "FortuneType" => "Fortune",
    "MainAttack" => "Guns",
    "SecondaryAttack" => "Martial Arts",
    "Wounds" => 0,
  }

  belongs_to :fight
  belongs_to :user, optional: true

  # before_save :add_default_action_values

  def add_default_action_values
    self.action_values ||= {}
    self.action_values = self.action_values.merge(DEFAULT_ACTION_VALUES)
  end

  def act!(shots=DEFAULT_SHOT_COUNT)
    self.current_shot ||= 0
    self.current_shot -= shots.to_i
    save!
  end
end
