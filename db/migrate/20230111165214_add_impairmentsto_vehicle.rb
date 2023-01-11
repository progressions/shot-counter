class AddImpairmentstoVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :impairments, :integer
  end
end
