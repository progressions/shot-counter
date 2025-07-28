class UserSerializer < ActiveModel::Serializer
  attributes :id, :first_name, :last_name, :image_url, :email, :name, :gamemaster
end
