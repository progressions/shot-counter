class Juncture < ApplicationRecord
  belongs_to :campaign
  belongs_to :faction, optional: true
  has_many :characters
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  after_update :broadcast_campaign_update

  def as_v1_json(args = {})
    {
      id: id,
      name: name,
      description: description,
      faction: faction&.as_v1_json(only: [:id, :name]),
      active: active,
      created_at: created_at,
      updated_at: updated_at,
      characters: characters.map do |character|
        {
          id: character.id,
          name: character.name,
          image_url: character.image.attached? ? character.image.url : nil
        }
      end,
      image_url: image_url
    }
  rescue StandardError => e
    Rails.logger.error "Error in Juncture#as_v1_json for juncture #{id}: #{e.message}"
    raise # Re-raise to help diagnose in controller
  end

  def image_url
    image.attached? ? image.url : nil
  end

  private

  def broadcast_campaign_update
    channel = "campaign_#{campaign_id}"
    payload = { juncture: JunctureSerializer.new(self).as_json }
    ActionCable.server.broadcast(channel, payload)
    ActionCable.server.broadcast(channel, { junctures: "reload" })
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for juncture #{id}: #{e.message}"
  end
end
