class Party < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :characters, through: :memberships
  belongs_to :campaign

  def as_json(options = {})
    {
      id: id,
      name: name,
      description: description,
      characters: characters.map { |character|
        {
          id: character.id,
          name: character.name,
        }
      },
    }
  end
end
