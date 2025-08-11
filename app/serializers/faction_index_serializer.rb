class FactionIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :created_at, :updated_at, :image_url, :entity_class, :active, :characters

  has_many :characters, serializer: CharacterAutocompleteSerializer
  has_many :vehicles, serializer: VehicleLiteSerializer
  has_many :junctures, serializer: JunctureLiteSerializer

  def entity_class
    object.class.name
  end
end
