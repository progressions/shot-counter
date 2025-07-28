class AddCaseInsensitiveIndexToCharacterName < ActiveRecord::Migration[8.0]
  def change
    add_index :characters, "LOWER(name)", name: "index_characters_on_lower_name"
  end
end
