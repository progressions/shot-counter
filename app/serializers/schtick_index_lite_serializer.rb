class SchtickIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :description, :category, :path, :created_at, :updated_at, :entity_class, :prerequisite_id
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end

