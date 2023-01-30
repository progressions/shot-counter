class AddJunctureToWeapon < ActiveRecord::Migration[7.0]
  def change
    add_column :weapons, :juncture, :string
  end
end
