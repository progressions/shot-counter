# app/serializers/character_autocomplete_serializer.rb
class CharacterAutocompleteSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :entity_class

  def entity_class
    object.class.name
  end
end
