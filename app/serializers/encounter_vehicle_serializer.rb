# app/serializers/encounter_vehicle_serializer.rb
class EncounterVehicleSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values
end
