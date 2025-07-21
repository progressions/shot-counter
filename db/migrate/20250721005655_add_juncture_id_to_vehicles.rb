class AddJunctureIdToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :juncture_id, :uuid
    add_index :vehicles, :juncture_id
    add_foreign_key :vehicles, :junctures
  end
end
