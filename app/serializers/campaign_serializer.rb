class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :gamemaster_id, :gamemaster, :created_at, :updated_at, :players, :player_ids, :image_url

  def gamemaster
    UserSerializer.new(object.user, scope: scope, root: false)
  end

  def gamemaster_id
    object.user_id
  end
end
