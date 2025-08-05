# app/serializers/encounter_character_serializer.rb
class EncounterCharacterSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values
end
