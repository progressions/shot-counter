class Membership < ApplicationRecord
  belongs_to :character
  belongs_to :party
end
