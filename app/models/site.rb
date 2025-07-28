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
    return unless image_attachment && image_attachment.blob
    if Rails.env.production?
      image.attached? ? image.url : nil
    else
      Rails.application.routes.url_helpers.rails_blob_url(image_attachment.blob, only_path: true)
    end
  end

  private

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = { site: as_json }
    ActionCable.server.broadcast(channel, payload)
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for juncture #{id}: #{e.message}"
  end
end
