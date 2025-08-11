class CampaignIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :player_ids, :entity_class, :active, :created_at, :updated_at, :gamemaster, :gamemaster_id
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :characters, serializer: CharacterIndexSerializer

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
