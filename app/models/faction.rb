class Faction < ApplicationRecord
  belongs_to :campaign
  has_many :characters
  has_many :sites
  has_many :junctures
  has_many :parties
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

  def image_url
    image.attached? ? image.url : nil
  end

  private

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = { faction: FactionSerializer.new(self).as_json }
    ActionCable.server.broadcast(channel, payload)
    ActionCable.server.broadcast(channel, { factions: "reload" })
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for juncture #{id}: #{e.message}"
  end
end
