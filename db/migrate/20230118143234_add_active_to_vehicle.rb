class AddActiveToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :active, :boolean, null: false, default: true
  end
end
