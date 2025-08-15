# app/serializers/faction_autocomplete_serializer.rb
class FactionAutocompleteSerializer < ActiveModel::Serializer
  attributes :id, :name, :entity_class

  def entity_class
    object.class.name
  end
end
