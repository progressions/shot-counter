class CampaignLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :gamemaster_id, :gamemaster, :created_at, :updated_at, :users, :user_ids, :image_url, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer

  def gamemaster
    UserSerializer.new(object.user, scope: scope, root: false)
  end

  def gamemaster_id
    object.user_id
  end

  def entity_class
    object.class.name
  end
end
