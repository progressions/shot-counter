class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :image_url, :email, :name, :gamemaster, :admin, :entity_class, :active, :created_at, :updated_at
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
