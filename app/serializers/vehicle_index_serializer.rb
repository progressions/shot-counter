class VehicleIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values, :created_at, :updated_at, :image_url, :description, :entity_class
  belongs_to :faction, optional: true
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
