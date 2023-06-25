class AddFightCharacterToCharacterEffects < ActiveRecord::Migration[7.0]
  def change
    add_reference :character_effects, :fight_character, foreign_key: true, type: :uuid
  end
end
