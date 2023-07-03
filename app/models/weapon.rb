class Weapon < ApplicationRecord
  belongs_to :campaign
  has_many :carries
  has_many :characters, through: :carries

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validates :damage, presence: true
end
