class Site < ApplicationRecord
  belongs_to :campaign
  belongs_to :faction, optional: true
  has_many :attunements, dependent: :destroy
  has_many :characters, through: :attunements
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
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
      image_url: image_url
    }
  end

  def image_url
    image.attached? ? image.url : nil
  rescue
  end

  private

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = { site: SiteSerializer.new(self).as_json }
    ActionCable.server.broadcast(channel, payload)
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for site #{id}: #{e.message}"
  end
end
