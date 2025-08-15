class SchtickAutocompleteSerializer < ActiveModel::Serializer
  attributes :id, :name, :category, :path, :image_url, :entity_class

  def entity_class
    object.class.name
  end
end
