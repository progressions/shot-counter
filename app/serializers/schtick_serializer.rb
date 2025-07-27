class SchtickSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :category, :path, :image_url
end
