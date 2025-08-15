# app/serializers/encounter_vehicle_serializer.rb
class EncounterVehicleSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values, :entity_class

  def entity_class
    object.class.name
  end
end
