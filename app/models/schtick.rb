class Schtick < ApplicationRecord
  belongs_to :campaign
  belongs_to :prerequisite, class_name: "Schtick", optional: true
  has_many :character_schticks
  has_many :characters, through: :character_schticks

  validates :title, presence: true, uniqueness: true

  def as_json(args={})
    {
      id: id,
      title: title,
      description: description,
      category: category,
      path: path,
      prerequisite: {
        id: prerequisite&.id,
        title: prerequisite&.title,
      }
    }
  end

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
