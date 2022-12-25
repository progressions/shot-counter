class Fight < ApplicationRecord
  has_many :characters, dependent: :destroy

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
    characters
      .group_by { |char| char.current_shot }
      .sort_by { |shot, chars| -shot.to_i }
      .map { |shot, chars| [shot, chars.sort_by(&:name)] }
  end
end
