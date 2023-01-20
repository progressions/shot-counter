class CharacterEffect < ApplicationRecord
  belongs_to :character
  belongs_to :fight

  def as_json(args={})
    {
      id: id,
      title: title,
      character: {
        id: character.id
      },
      fight: {
        id: fight.id
      }
    }
  end
end
