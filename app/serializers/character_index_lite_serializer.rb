# app/serializers/character_index_lite_serializer.rb
class CharacterIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :faction_id, :juncture_id, :action_values, :created_at, :updated_at, :description, :entity_class, :skills, :is_template
  belongs_to :faction, serializer: FactionLiteSerializer
  belongs_to :juncture, serializer: JunctureLiteSerializer
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end
