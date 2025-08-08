class PartyIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :secret, :created_at, :updated_at, :faction_id, :campaign_id, :image_url
  has_many :characters, serializer: CharacterAutocompleteSerializer do
    object.memberships.map { |m| m.character }.compact
  end
  has_many :vehicles, serializer: VehicleLiteSerializer do
    object.memberships.map { |m| m.vehicle }.compact
  end
  belongs_to :faction, optional: true, serializer: FactionLiteSerializer
  has_many :image_positions, serializer: ImagePositionSerializer
end
