class Attunement < ApplicationRecord
  belongs_to :character
  belongs_to :site

  validates :character, presence: true, uniqueness: { scope: :site_id }
  validates :site, presence: true
end
