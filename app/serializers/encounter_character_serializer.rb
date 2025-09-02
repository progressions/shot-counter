# app/serializers/encounter_character_serializer.rb
class EncounterCharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values, :entity_class, :impairments

  def entity_class
    object.class.name
  end
end
