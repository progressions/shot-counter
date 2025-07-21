class AddWealthToCharacter < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :wealth, :string
  end
end
