class FactionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :active
end
