class Campaign < ApplicationRecord
  include Broadcastable
  include WithImagekit
  include OnboardingTrackable

  belongs_to :user
  has_many :fights
  has_many :characters
  has_many :vehicles
  has_many :campaign_memberships
  has_many :users, through: :campaign_memberships
  has_many :invitations
  has_many :schticks
  has_many :weapons
  has_many :parties
  has_many :sites
  has_many :factions
  has_many :junctures
  has_one_attached :image
  has_many :image_positions, as: :positionable, dependent: :destroy

  validates :name, presence: true, allow_blank: false, uniqueness: { scope: :user_id }

  after_create :enqueue_seeding_job, unless: :is_master_template?

  def as_v1_json(args={})
    {
      id: id,
      name: name,
      description: description,
      gamemaster: user,
      users: users,
      invitations: invitations,
    }
  end

  private

  def enqueue_seeding_job
    CampaignSeederJob.perform_later(id)
  end

  def broadcast_campaign_update
    user_camp_ids = user.campaigns.map { |campaign| campaign.id }
    user_camp_ids = users.map { |user| user.current_campaign_id }
    campaign_ids = user_camp_ids + user_camp_ids

    campaign_ids.uniq.each do |campaign_id|
      channel = "campaign_#{campaign_id}"
      payload = {
        campaign: CampaignSerializer.new(self).as_json,
      }
      ActionCable.server.broadcast(channel, payload)
    end
  end

  def broadcast_reload
    payload = { campaigns: "reload" }
    
    # Broadcast to user-specific channel for campaign list updates
    user_channel = "user_#{user.id}"
    ActionCable.server.broadcast(user_channel, payload)
    
    # Also broadcast to this campaign's channel if it exists
    channel = "campaign_#{id}"
    ActionCable.server.broadcast(channel, payload)
  end
end
