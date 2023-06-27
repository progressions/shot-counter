class RemoveFightIdFromCharacterEffect < ActiveRecord::Migration[7.0]
  def change
    remove_column :character_effects, :fight_id
  end
end
