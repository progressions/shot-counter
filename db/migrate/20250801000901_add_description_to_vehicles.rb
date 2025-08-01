class AddDescriptionToVehicles < ActiveRecord::Migration[8.0]
  def change
    add_column :vehicles, :description, :jsonb
  end
end
