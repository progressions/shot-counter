class PartySerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :secret, :created_at, :updated_at, :faction_id, :campaign_id
  has_many :characters
  has_many :vehicles
  belongs_to :faction, optional: true
end
