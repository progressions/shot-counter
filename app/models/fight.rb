class Fight < ApplicationRecord
  has_many :fight_characters, dependent: :destroy
  has_many :characters, through: :fight_characters

  def as_json(args)
    {
      id: id,
      name: name,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters,
      shot_order: shot_order,
    }
  end

  def shot_order
    fight_characters
      .includes(:character)
      .includes(character: :user)
      .group_by { |fc| fc.shot }
      .sort_by { |shot, fight_chars| -shot.to_i }
      .map { |shot, fight_chars|
        [shot, fight_chars
                 .map { |fc| fc.character }
                 .sort_by { |char| char.name }
        ]
      }
  end
end
