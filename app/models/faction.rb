class Faction < ApplicationRecord
  belongs_to :campaign
  has_many :factions
  has_many :characters
  has_many :sites
  has_many :parties
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  def as_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      active: self.active,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters.map { |character|
        {
          id: character.id,
          name: character.name,
          image_url: character.image_url,
        }
      },
      image_url: image_url
    }
  end

  def image_url
    image.attached? ? image.url : nil
  end
end
