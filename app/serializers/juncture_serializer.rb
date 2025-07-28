class JunctureSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :active, :faction_id, :created_at, :updated_at
  belongs_to :faction, optional: true
end
