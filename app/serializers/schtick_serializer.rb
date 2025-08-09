class SchtickSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :category, :path, :image_url, :color, :archetypes, :prerequisite_id, :bonus, :campaign_id, :created_at, :updated_at, :entity_class
  has_many :image_positions, serializer: ImagePositionSerializer
  belongs_to :prerequisite, serializer: SchtickAutocompleteSerializer

  def entity_class
    object.class.name
  end
end
