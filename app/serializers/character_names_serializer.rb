class CharacterNamesSerializer < ActiveModel::Serializer
  attributes :id, :name, :entity_class

  def entity_class
    object.class.name
  end
end
