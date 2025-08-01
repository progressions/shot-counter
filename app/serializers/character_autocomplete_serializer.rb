# app/serializers/character_autocomplete_serializer.rb
class CharacterAutocompleteSerializer < ActiveModel::Serializer
  attributes :id, :name
end
