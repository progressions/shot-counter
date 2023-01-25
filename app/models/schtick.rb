class Schtick < ApplicationRecord
  belongs_to :campaign
  belongs_to :prerequisite, class_name: "Schtick", optional: true
  has_many :character_schticks
  has_many :characters, through: :character_schticks

  validates :title, presence: true, uniqueness: true

  def self.for_archetype(archetype)
    where("archetypes @> ?", [archetype].flatten.to_json)
  end

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
      },
      archetypes: archetypes
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
