class CharacterIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :task, :image_url, :user_id, :faction_id, :action_values, :created_at, :active, :entity_class, :description
  belongs_to :user, serializer: UserSerializer
  belongs_to :faction, serializer: FactionSerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def user_id
    object[:user_id]
  end

  def entity_class
    object.class.name
  end
end
