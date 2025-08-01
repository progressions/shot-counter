class VehicleSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values, :task, :active, :created_at, :updated_at, :image_url
  belongs_to :faction, optional: true
end
