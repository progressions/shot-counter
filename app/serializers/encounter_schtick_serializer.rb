class EncounterSchtickSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :entity_class

  def entity_class
    object.class.name
  end
end
