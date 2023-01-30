class Schtick < ApplicationRecord
  belongs_to :campaign
  belongs_to :prerequisite, class_name: "Schtick", optional: true
  has_many :character_schticks
  has_many :characters, through: :character_schticks

  validates :title, presence: true, uniqueness: { scope: :category }

  COLORS = {
    "Guns" => "#b71c1c",
    "Martial Arts" => "#4a148c",
    "Driving"=> "#311b92",
    "Sorcery"=> "#0d47a1",
    "Creature"=> "#006064",
    "Transformed Animal"=> "#1b5e20",
    "Gene Freak"=> "#9e9d24",
    "Cyborg"=> "#ff8f00",
    "Foe" => "#bf360c",
    "Core" => "#3e2723"
  }

  def self.for_archetype(archetype)
    where("schticks.archetypes @> ?", [archetype].flatten.to_json)
  end

  def as_json(args={})
    {
      id: id,
      title: title,
      description: description,
      category: category,
      path: path,
      color: color,
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
