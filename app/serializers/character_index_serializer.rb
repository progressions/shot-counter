class CharacterIndexSerializer < ActiveModel::Serializer
  attributes :id, :name, :defense, :impairments, :color, :image_url, :user_id, :faction_id, :action_values, :created_at, :active
  belongs_to :user, serializer: UserSerializer
  belongs_to :faction, serializer: FactionSerializer

  def image_url
    object.image.attached? ? Rails.application.routes.url_helpers.url_for(object.image) : object.image_url
  end

  def user_id
    object[:user_id]
  end
end
