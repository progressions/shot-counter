class AddDriverForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :shots, :shots, column: :driver_id
    add_foreign_key :shots, :shots, column: :driving_id
  end
end
