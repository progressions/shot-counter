class JunctureSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :image_url, :faction, :active

  def image_url
    object.image.attached? ? object.image_url : nil
  end
end
