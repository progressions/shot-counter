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

  def campaign_id
    # Campaign model references itself for broadcasting compatibility
    id
  end

  private

  def enqueue_seeding_job
    CampaignSeederJob.perform_later(id)
  end

end
