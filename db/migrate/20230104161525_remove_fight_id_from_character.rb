class RemoveFightIdFromCharacter < ActiveRecord::Migration[7.0]
  def change
    remove_column :characters, :fight_id
  end
end
