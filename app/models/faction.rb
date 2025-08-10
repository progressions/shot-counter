class Faction < ApplicationRecord
  include Broadcastable
  include WithImagekit

  belongs_to :campaign
  has_many :characters
  has_many :vehicles
  has_many :sites
  has_many :junctures
  has_many :parties
  has_many :image_positions, as: :positionable, dependent: :destroy
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
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

end
