class AdvancementSerializer < ActiveModel::Serializer
  attributes :id, :description, :created_at, :updated_at, :character_id
end
