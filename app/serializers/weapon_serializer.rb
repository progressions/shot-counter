class WeaponSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :created_at, :damage, :concealment, :reload_value, :description, :juncture, :category, :mook_bonus, :kachunk, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
