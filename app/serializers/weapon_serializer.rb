class WeaponSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :created_at, :damage, :concealment, :reload_value

  def image_url
    object.image_url
  end
end
