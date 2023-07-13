class Mook < ApplicationRecord
  has_one :shot, dependent: :nullify

  delegate :character, to: :shot
  delegate :vehicle, to: :shot

  validates :character, presence: true, if: -> { vehicle.nil? }
  validates :vehicle, presence: true, if: -> { character.nil? }

  # ensure that the associated character has a mook action value
  # validate :ensure_mook_action_value

  def ensure_mook_action_value
    if character && character.action_values["Type"] != "Mook"
      errors.add(:character, "must have a mook action value")
    end
  end
end
