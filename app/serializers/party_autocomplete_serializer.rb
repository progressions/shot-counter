class PartyAutocompleteSerializer < ActiveModel::Serializer
  attributes :id, :name, :entity_class, :character_ids, :vehicle_ids

  def entity_class
    object.class.name
  end
end
