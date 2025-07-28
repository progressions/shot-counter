class CarrySerializer < ActiveModel::Serializer
  attributes :id
  belongs_to :weapon, serializer: WeaponSerializer
end
