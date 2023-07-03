class CampaignMembership < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  validates :user, presence: true, uniqueness: { scope: :campaign_id }
  validates :campaign, presence: true
end
