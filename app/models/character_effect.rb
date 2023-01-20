class CharacterEffect < ApplicationRecord
  belongs_to :character
  belongs_to :fight

  def as_json(args={})
    {
      id: id,
      title: title,
    }
  end
end
