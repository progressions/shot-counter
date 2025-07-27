class JunctureSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :faction, :active
end
