class Fight < ApplicationRecord
  has_many :characters

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
      .sort_by { |shot, chars| -shot }
  end
end
