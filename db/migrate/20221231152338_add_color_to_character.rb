class AddColorToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :color, :string
  end
end
