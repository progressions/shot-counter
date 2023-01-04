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
      .joins(:character)
      .group_by { |fc| fc.shot }
      .sort_by { |shot, fight_chars| -shot.to_i }
      .map { |shot, fight_chars|
        [shot, fight_chars
                 .map { |fc| fc.character }
                 .sort_by { |char| char.name }
        ]
      }
  end

  def old_shot_order
    characters
      .group_by { |char| char.current_shot }
      .sort_by { |shot, chars| -shot.to_i }
      .map { |shot, chars| [shot, chars.sort_by(&:name)] }
  end
end
