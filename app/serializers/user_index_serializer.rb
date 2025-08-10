class UserIndexSerializer < ActiveModel::Serializer
  attributes :id, :email, :first_name, :last_name, :admin, :gamemaster, :image_url, :name, :created_at, :updated_at, :entity_class, :active
  has_many :campaigns, serializer: CampaignLiteSerializer

  def entity_class
    object.class.name
  end
end
