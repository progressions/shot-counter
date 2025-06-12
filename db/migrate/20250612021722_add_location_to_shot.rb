class AddLocationToShot < ActiveRecord::Migration[8.0]
  def change
    add_column :shots, :location, :string
  end
end
