class SiteIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :juncture_id, :entity_class
  has_many :characters, serializer: CharacterAutocompleteSerializer do
    object.attunements.map { |m| m.character }.compact
  end
  belongs_to :faction, optional: true, serializer: FactionLiteSerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
