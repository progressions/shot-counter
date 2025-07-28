class SiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :secret, :created_at, :updated_at, :faction_id, :campaign_id
  belongs_to :faction, optional: true
end
