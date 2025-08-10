class CampaignIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :player_ids, :entity_class, :active, :created_at, :updated_at
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :characters, serializer: CharacterIndexSerializer

  def entity_class
    object.class.name
  end
end
