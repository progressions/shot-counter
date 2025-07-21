class Juncture < ApplicationRecord
  belongs_to :campaign
  belongs_to :faction
  has_many :characters
end
