class FactionSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url
end
