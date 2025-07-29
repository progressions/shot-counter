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
    image.attached? ? image.url : nil
  end

  private

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = { weapon: WeaponSerializer.new(self).as_json }
    ActionCable.server.broadcast(channel, payload)
    # ActionCable.server.broadcast(channel, { weapons: "reload" })
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for juncture #{id}: #{e.message}"
  end
end
