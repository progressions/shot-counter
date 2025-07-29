class SiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :secret, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :character_ids
  has_many :characters, serializer: CharacterSerializer
  belongs_to :faction, optional: true
end
