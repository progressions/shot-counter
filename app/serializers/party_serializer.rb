class PartySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :character_ids, :characters, :vehicles, :faction, :entity_class, :juncture_id
  has_many :characters, serializer: CharacterSerializer
  has_many :vehicles, serializer: VehicleSerializer
  belongs_to :faction, optional: true, serializer: FactionSerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def characters
    object.characters.order("characters.name ASC")
  end

  def entity_class
    object.class.name
  end
end
