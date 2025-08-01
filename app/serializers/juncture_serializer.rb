class JunctureSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :active, :faction_id, :created_at, :updated_at, :character_ids
  has_many :characters, serializer: CharacterSerializer do
    object.characters.order(:name)
  end
  belongs_to :faction, optional: true
end
