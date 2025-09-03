class VehicleSerializer < ActiveModel::Serializer
  attributes :id, :name, :action_values, :task, :active, :created_at, :updated_at, :image_url, :description, :entity_class, :faction_id, :juncture_id, :user_id
  belongs_to :faction, serializer: FactionLiteSerializer, optional: true
  belongs_to :user, serializer: UserLiteSerializer
  belongs_to :juncture, serializer: JunctureLiteSerializer, optional: true
  has_many :image_positions, serializer: ImagePositionSerializer

  def entity_class
    object.class.name
  end
end