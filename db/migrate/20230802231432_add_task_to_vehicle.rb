class AddTaskToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :task, :boolean
  end
end
