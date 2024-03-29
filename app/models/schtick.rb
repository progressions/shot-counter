class Schtick < ApplicationRecord
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

  belongs_to :campaign
  belongs_to :prerequisite, class_name: "Schtick", optional: true
  has_many :character_schticks
  has_many :characters, through: :character_schticks

  validates :name, presence: true, uniqueness: { scope: :category }
  validates :category, inclusion: { in: CATEGORIES }, allow_nil: true, unless: -> { path == "Core" }
  validate :prerequisite_must_be_in_same_category_and_path

  def self.for_archetype(archetype)
    where("schticks.archetypes @> ?", [archetype].flatten.to_json)
  end

  def as_json(args={})
    {
      id: id,
      name: name,
      description: description,
      category: category,
      path: path,
      color: color,
      prerequisite: {
        id: prerequisite&.id,
        name: prerequisite&.name,
      },
      archetypes: archetypes
    }
  end

  def prerequisite_must_be_in_same_category_and_path
    return unless prerequisite
    return if prerequisite.category == category && prerequisite.path == path

    errors.add(:prerequisite, "must be in the same category and path")
  end

end
