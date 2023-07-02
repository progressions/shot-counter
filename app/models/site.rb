class Site < ApplicationRecord
  belongs_to :campaign
  belongs_to :faction, optional: true
  has_many :attunements
  has_many :characters, through: :attunements

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
end
