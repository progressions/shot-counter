class AddImpairmentsToShot < ActiveRecord::Migration[7.0]
  def change
    add_column :shots, :impairments, :integer, default: 0
  end
end
