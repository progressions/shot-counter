class AddActiveToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :active, :boolean, null: false, default: true
  end
end
