class FightIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :entity_class, :started_at, :ended_at, :campaign_id, :season, :session, :image_url
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :characters, serializer: CharacterAutocompleteSerializer
  has_many :vehicles, serializer: VehicleLiteSerializer

  def characters
    object.shots.map { |shot| shot.character }.compact.uniq
  end

  def vehicles
    object.shots.map { |shot| shot.vehicle }.compact.uniq
  end

  def entity_class
    object.class.name
  end
end
