class AddCountToShot < ActiveRecord::Migration[7.0]
  def change
    add_column :shots, :count, :integer, default: 0
    add_column :shots, :color, :string
  end
end
