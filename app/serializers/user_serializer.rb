class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :image_url, :email, :name, :gamemaster, :admin, :entity_class, :active, :created_at, :updated_at
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :campaigns, serializer: CampaignIndexLiteSerializer
  has_many :player_campaigns, through: :campaign_memberships, source: :campaign, serializer: CampaignIndexLiteSerializer
  has_one :onboarding_progress, serializer: OnboardingProgressSerializer

  def entity_class
    object.class.name
  end
end
