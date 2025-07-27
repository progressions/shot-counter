class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :image_url

  def image_url
    object.image_url
  end
end
