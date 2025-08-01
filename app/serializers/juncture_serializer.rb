class JunctureSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :active, :faction_id, :created_at, :updated_at, :character_ids, :entity_class
  has_many :characters, serializer: CharacterSerializer do
    object.characters.order(:name)
  end
  belongs_to :faction, optional: true
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
