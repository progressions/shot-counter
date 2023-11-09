class RemoveDriverForeignKeys < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :shots, :characters, column: :driver_id
    remove_foreign_key :shots, :vehicles, column: :driving_id
  end
end
