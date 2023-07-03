class CharacterSchtick < ApplicationRecord
  belongs_to :character
  belongs_to :schtick

  validates :character_id, uniqueness: { scope: :schtick_id }
end
