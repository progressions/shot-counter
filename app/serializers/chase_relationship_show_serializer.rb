class ChaseRelationshipShowSerializer < ActiveModel::Serializer
  attributes :id, :pursuer_id, :evader_id, :fight_id, :position, :active, :created_at, :updated_at
  
  has_one :pursuer, serializer: VehicleSerializer
  has_one :evader, serializer: VehicleSerializer
end