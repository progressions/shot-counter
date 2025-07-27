class Campaign < ApplicationRecord
  belongs_to :user
  has_many :fights
  has_many :characters
  has_many :vehicles
  has_many :campaign_memberships
  has_many :players, through: :campaign_memberships, source: "user"
  has_many :invitations
  has_many :schticks
  has_many :weapons
  has_many :parties
  has_many :sites
  has_many :factions
  has_many :junctures
  has_one_attached :image

  validates :name, presence: true, allow_blank: false

  after_update :broadcast_campaign_update, if: -> { saved_change_to_name? || saved_change_to_description? }

  def as_v1_json(args={})
    {
      id: id,
      name: name,
      description: description,
      gamemaster: user,
      players: players,
      invitations: invitations,
    }
  end

  def broadcast_campaign_update
    user_camp_ids = user.campaigns.map { |campaign| campaign.id }
    player_camp_ids = players.map { |player| player.current_campaign_id }
    campaign_ids = user_camp_ids + player_camp_ids

    campaign_ids.uniq.each do |campaign_id|
      channel = "campaign_#{campaign_id}"
      payload = {
        campaign: self.as_json
      }
      ActionCable.server.broadcast(channel, payload)
    end
  end
end
