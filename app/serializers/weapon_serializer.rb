class WeaponSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :created_at, :damage, :concealment, :reload_value, :description
end
