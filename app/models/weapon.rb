class Weapon < ApplicationRecord
  belongs_to :campaign
  has_many :carries
  has_many :characters, through: :carries
  has_one_attached :image

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
  validates :damage, presence: true
end
