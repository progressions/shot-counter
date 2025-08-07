# app/serializers/character_index_lite_serializer.rb
class CharacterIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :faction_id, :action_values, :created_at, :updated_at, :description, :entity_class, :skills, :schticks
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
