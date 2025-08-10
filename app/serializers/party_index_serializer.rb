class PartyIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :juncture_id, :entity_class
  has_many :characters, serializer: CharacterAutocompleteSerializer do
    object.memberships.map { |m| m.character }.compact
  end
  has_many :vehicles, serializer: VehicleLiteSerializer do
    object.memberships.map { |m| m.vehicle }.compact
  end
  belongs_to :faction, optional: true, serializer: FactionLiteSerializer
  belongs_to :juncture, optional: true, serializer: JunctureLiteSerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
