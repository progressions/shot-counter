class Faction < ApplicationRecord
  belongs_to :campaign
  has_many :factions
  has_many :characters
  has_many :sites
  has_many :parties

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
end
