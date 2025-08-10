class FightIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :entity_class, :started_at, :ended_at, :campaign_id, :season, :session
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :characters, serializer: CharacterAutocompleteSerializer
  has_many :vehicles, serializer: VehicleLiteSerializer

  def entity_class
    object.class.name
  end
end
