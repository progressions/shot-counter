class Schtick < ApplicationRecord
  belongs_to :campaign
  belongs_to :schtick, optional: true
  has_many :character_schticks
  has_many :characters, through: :character_schticks

  validates :title, presence: true, uniqueness: true

  CATEGORIES = [
    "Guns",
    "Martial Arts",
    "Driving",
    "Sorcery",
    "Creature",
    "Transformed Animal",
    "Gene Freak",
    "Cyborg",
    "Foe"
  ]
end
