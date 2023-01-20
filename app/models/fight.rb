class Fight < ApplicationRecord
  belongs_to :campaign
  has_many :fight_characters, dependent: :destroy
  has_many :characters, through: :fight_characters
  has_many :vehicles, through: :fight_characters
  has_many :effects, dependent: :destroy
  has_many :character_effects

  SORT_ORDER = ["Uber-Boss", "PC", "Boss", "Featured Foe", "Ally", "Mook"]
  DEFAULT_SHOT_COUNT = 3

  def as_json(args)
    {
      id: id,
      name: name,
      active: active,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters,
      vehicles: vehicles,
      shot_order: shot_order,
      sequence: sequence,
      effects: effects,
      character_effects: character_effects
    }
  end

  def shot_order
    fight_characters
      .includes(:character)
      .includes(:vehicle)
      .includes(character: :user)
      .includes(vehicle: :user)
      .group_by { |fc| fc.shot }
      .sort_by { |shot, fight_chars| -shot.to_i }
      .map { |shot, fight_chars|
        [shot, fight_chars
                 .map { |fc| fc.character || fc.vehicle }
                 .compact
                 .sort_by(&:sort_order)
        ]
      }
  end

end
