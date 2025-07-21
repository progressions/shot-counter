class Juncture < ApplicationRecord
  belongs_to :faction
  has_many :characters
end
