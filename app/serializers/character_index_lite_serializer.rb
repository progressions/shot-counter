# app/serializers/character_index_lite_serializer.rb
class CharacterIndexLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url, :faction_id, :action_values, :created_at, :updated_at

  def image_url
    object.image.attached? ? Rails.application.routes.url_helpers.url_for(object.image) : object.image_url
  end
end
