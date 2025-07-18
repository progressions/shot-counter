class Site < ApplicationRecord
  belongs_to :campaign
  belongs_to :faction, optional: true
  has_many :attunements, dependent: :destroy
  has_many :characters, through: :attunements
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  def as_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      faction: faction,
      secret: self.secret,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters.map { |character|
        {
          id: character.id,
          name: character.name,
          image_url: character.image_url,
        }
      },
      image_url: image.attached? ? image.url : nil,
    }
  end
end
