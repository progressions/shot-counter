class SiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :image_url

  def image_url
    object.image_url
  end
end
