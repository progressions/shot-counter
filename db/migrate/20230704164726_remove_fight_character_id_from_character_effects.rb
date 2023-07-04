class RemoveFightCharacterIdFromCharacterEffects < ActiveRecord::Migration[7.0]
  def change
    remove_column :character_effects, :fight_character_id, :integer
  end
end
