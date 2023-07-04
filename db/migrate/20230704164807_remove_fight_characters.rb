class RemoveFightCharacters < ActiveRecord::Migration[7.0]
  def change
    drop_table :fight_characters
  end
end
