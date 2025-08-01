class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :image_url, :email, :name, :gamemaster, :admin, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
