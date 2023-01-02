class Character < ApplicationRecord
  DEFAULT_SHOT_COUNT = 3
  DEFAULT_ACTION_VALUES = {
    "Guns" => nil,
    "Martial Arts" => nil,
    "Sorcery" => nil,
    "Scroungetech" => nil,
    "Genome" => nil,
    "Defense" => nil,
    "Toughness" => nil,
    "Speed" => nil,
    "Fortune" => nil,
    "Max Fortune" => nil,
    "FortuneType" => "Fortune",
    "MainAttack" => "Guns",
    "SecondaryAttack" => "Martial Arts",
    "Wounds" => 0,
  }

  belongs_to :fight
  belongs_to :user, optional: true

  after_initialize :ensure_default_action_values
  before_save :ensure_default_action_values

  def act!(shots=DEFAULT_SHOT_COUNT)
    self.current_shot ||= 0
    self.current_shot -= shots.to_i
    save!
  end

  private

  def ensure_default_action_values
    self.action_values ||= {}
    self.action_values = DEFAULT_ACTION_VALUES.merge(self.action_values)
  end
end
