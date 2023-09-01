class Party < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :characters, through: :memberships
  has_many :vehicles, through: :memberships
  belongs_to :faction, optional: true
  belongs_to :campaign
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  def as_json(options = {})
    {
      id: id,
      name: name,
      description: description,
      faction: faction,
      secret: secret,
      characters: characters.map { |character|
        {
          id: character.id,
          name: character.name,
          category: "character",
        }
      },
      vehicles: vehicles.map { |vehicle|
        {
          id: vehicle.id,
          name: vehicle.name,
          category: "vehicle",
        }
      },
    }
  end
end
