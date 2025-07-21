class AddJunctureIdToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :juncture_id, :uuid
    add_index :characters, :juncture_id
    add_foreign_key :characters, :junctures
  end
end
