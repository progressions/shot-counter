class Faction < ApplicationRecord
  belongs_to :campaign
  has_many :characters

  validates :name, presence: true, uniqueness: { scope: :campaign_id }
end
