class InvitationSerializer < ActiveModel::Serializer
  attributes :id, :email, :maximum_count, :remaining_count, :gamemaster, :campaign, :pending_user

  def gamemaster
    object.user
  end
end
