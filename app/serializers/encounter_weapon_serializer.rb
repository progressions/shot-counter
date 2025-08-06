class EncounterWeaponSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :entity_class, :damage, :concealment, :reload_value

  def entity_class
    object.class.name
  end
end
