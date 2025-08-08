class VehicleLiteSerializer < ActiveModel::Serializer
  attributes :id, :name

  def entity_class
    object.class.name
  end
end
