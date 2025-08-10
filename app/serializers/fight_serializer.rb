class FightSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :created_at, :updated_at,
    :active, :sequence, :characters, :character_ids, :vehicles, :vehicle_ids,
    :entity_class, :started_at, :ended_at, :season, :session
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :characters, serializer: CharacterAutocompleteSerializer
  has_many :vehicles, serializer: VehicleLiteSerializer

  def entity_class
    object.class.name
  end
end
