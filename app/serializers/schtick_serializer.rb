class SchtickSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :category, :path, :image_url, :color, :archetypes, :prerequisite_id, :bonus, :campaign_id, :created_at, :updated_at
end
