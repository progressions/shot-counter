class FactionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :active, :character_ids, :site_ids, :juncture_ids, :party_ids, :created_at, :updated_at
  has_many :characters, serializer: CharacterSerializer
  has_many :sites, serializer: SiteSerializer
  has_many :junctures, serializer: JunctureSerializer
  has_many :parties, serializer: PartySerializer
end
