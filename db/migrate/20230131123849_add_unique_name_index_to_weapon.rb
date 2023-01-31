class AddUniqueNameIndexToWeapon < ActiveRecord::Migration[7.0]
  def change
    add_index :weapons, [:campaign_id, :name], unique: true
  end
end
