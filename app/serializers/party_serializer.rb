class PartySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :secret, :created_at, :updated_at, :faction_id, :campaign_id, :image_url, :character_ids, :characters, :vehicles, :faction
  has_many :characters, serializer: CharacterSerializer
  has_many :vehicles, serializer: VehicleSerializer
  belongs_to :faction, optional: true, serializer: FactionSerializer
end
