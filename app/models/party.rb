class Party < ApplicationRecord
  has_many :memberships, dependent: :destroy
  has_many :characters, through: :memberships
  belongs_to :campaign
end
