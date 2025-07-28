class Party < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :characters, through: :memberships
  has_many :vehicles, through: :memberships
  belongs_to :faction, optional: true
  belongs_to :campaign
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }

  after_update :broadcast_campaign_update

  def as_v1_json(options = {})
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
          image_url: character.image.attached? ? character.image.url : nil,
          action_values: character.action_values,
          faction: character.faction,
        }
      },
      vehicles: vehicles.map { |vehicle|
        {
          id: vehicle.id,
          name: vehicle.name,
          category: "vehicle",
          image_url: vehicle.image.attached? ? vehicle.image.url : nil,
          action_values: vehicle.action_values,
          faction: vehicle.faction,
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
    payload = { party: PartySerializer.new(self).as_json }
    ActionCable.server.broadcast(channel, payload)
  rescue StandardError => e
    Rails.logger.error "Failed to broadcast campaign update for party #{id}: #{e.message}"
  end
end
