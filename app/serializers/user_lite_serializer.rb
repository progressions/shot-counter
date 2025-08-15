class UserLiteSerializer < ActiveModel::Serializer
  attributes :id, :name, :email, :entity_class

  def entity_class
    object.class.name
  end
end
