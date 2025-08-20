class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :name, :email, :gamemaster, :admin, 
             :created_at, :updated_at, :image_url, :entity_class, :active,
             :campaigns_as_gm_count, :campaigns_as_player_count

  has_many :campaigns, serializer: CampaignIndexLiteSerializer
  has_many :player_campaigns, through: :campaign_memberships, source: :campaign, serializer: CampaignIndexLiteSerializer

  def entity_class
    'User'
  end

  def campaigns_as_gm_count
    object.campaigns.count
  end

  def campaigns_as_player_count 
    object.player_campaigns.count
  end
end