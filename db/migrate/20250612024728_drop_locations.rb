class DropLocations < ActiveRecord::Migration[8.0]
  def change
    drop_table :locations
  end
end
