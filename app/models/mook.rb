class Mook < ApplicationRecord
  has_one :shot, dependent: :nullify

  delegate :character, to: :shot
  delegate :vehicle, to: :shot

  validates :character, presence: true, if: -> { vehicle.nil? }
  validates :vehicle, presence: true, if: -> { character.nil? }
end
