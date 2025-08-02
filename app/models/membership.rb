class Membership < ApplicationRecord
  belongs_to :character, optional: true
  belongs_to :vehicle, optional: true
  belongs_to :party
end
