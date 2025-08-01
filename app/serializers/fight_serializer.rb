class FightSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :created_at, :updated_at, :active, :sequence, :actors, :character_ids, :vehicles, :vehicle_ids, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer

  def actors
    object.characters.order("characters.name ASC")
  end

  def entity_class
    object.class.name
  end
end
