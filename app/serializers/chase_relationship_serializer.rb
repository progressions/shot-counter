class ChaseRelationshipSerializer < ActiveModel::Serializer
  attributes :id, :pursuer_id, :evader_id, :fight_id, :position, :active, :created_at, :updated_at
end