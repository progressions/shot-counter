class Weapon < ApplicationRecord
  belongs_to :campaign
  has_many :carries
  has_many :characters, through: :carries
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validates :damage, presence: true
  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      damage: damage,
      concealment: concealment,
      reload_value: reload_value,
      category: category,
      juncture: juncture,
      mook_bonus: mook_bonus,
      kachunk: kachunk,
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
    payload = { weapon: as_json }
    ActionCable.server.broadcast(channel, payload)
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for juncture #{id}: #{e.message}"
  end
end
