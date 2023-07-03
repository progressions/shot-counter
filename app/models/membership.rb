class Membership < ApplicationRecord
  belongs_to :character
  belongs_to :party

  validates :character_id, uniqueness: { scope: :party_id }
end
