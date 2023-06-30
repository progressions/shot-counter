class Party < ApplicationRecord
  has_many :memberships
  has_many :characters, through: :memberships
  belongs_to :campaign
end
