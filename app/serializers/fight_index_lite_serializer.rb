class FightIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
