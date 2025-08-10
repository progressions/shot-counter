class SiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :active, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :character_ids, :entity_class, :juncture_id
  has_many :characters, serializer: CharacterSerializer
  belongs_to :faction, optional: true
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
