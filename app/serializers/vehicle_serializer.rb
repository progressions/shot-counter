class VehicleSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values, :task, :active
  belongs_to :faction, optional: true
end
