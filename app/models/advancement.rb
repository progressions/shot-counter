class Advancement < ApplicationRecord
  belongs_to :character

  validates :character, presence: true
end
