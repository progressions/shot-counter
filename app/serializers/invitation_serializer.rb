class InvitationSerializer < ActiveModel::Serializer
  attributes :id, :email, :maximum_count, :remaining_count, :created_at, :updated_at
  
  belongs_to :user, serializer: UserSerializer, key: :gamemaster
  belongs_to :pending_user, serializer: UserSerializer, if: :pending_user?
  belongs_to :campaign, serializer: CampaignLiteSerializer
  
  def pending_user?
    object.pending_user.present?
  end
end
