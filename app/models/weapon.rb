class Weapon < ApplicationRecord
  belongs_to :campaign
  belongs_to :carry, optional: true
  has_many :characters, through: :carry

  validates :name, presence: true
  validates :damage, presence: true
end
