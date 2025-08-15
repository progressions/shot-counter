class JunctureIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :entity_class
  belongs_to :faction, optional: true, serializer: FactionLiteSerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
