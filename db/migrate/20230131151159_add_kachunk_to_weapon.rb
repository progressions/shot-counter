class AddKachunkToWeapon < ActiveRecord::Migration[7.0]
  def change
    add_column :weapons, :kachunk, :boolean
  end
end
