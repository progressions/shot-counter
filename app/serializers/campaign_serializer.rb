class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :gamemaster_id, :gamemaster, :created_at, :updated_at, :players

  def gamemaster
    object.user
  end

  def gamemaster_id
    object.user_id
  end
end
