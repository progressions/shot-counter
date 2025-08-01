class FactionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :active, :character_ids, :site_ids, :juncture_ids, :party_ids, :created_at, :updated_at, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer
  has_many :characters, serializer: CharacterSerializer do
    object.characters.order(:name)
  end
  has_many :sites, serializer: SiteSerializer do
    object.sites.order(:name)
  end
  has_many :junctures, serializer: JunctureSerializer do
    object.junctures.order(:name)
  end
  has_many :parties, serializer: PartySerializer do
    object.parties.order(:name)
  end

  def entity_class
    object.class.name
  end
end
