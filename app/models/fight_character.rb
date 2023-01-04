class FightCharacters < ApplicationRecord
  belongs_to :fight
  belongs_to :character
end
