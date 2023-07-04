class Membership < ApplicationRecord
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :party

  validates :character_id, uniqueness: { scope: :party_id }, allow_nil: true
  # Vehicle is not unique, a party could have several identical vehicles
end
