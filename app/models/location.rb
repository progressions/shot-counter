class Location < ApplicationRecord
  belongs_to :shot

  validates :name, presence: true
  validates :shot, presence: true

  delegate :character, :vehicle, to: :shot
end
