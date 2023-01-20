class CharacterEffect < ApplicationRecord
  belongs_to :character
  belongs_to :fight
end
