class RemoveLocationIdFromShots < ActiveRecord::Migration[8.0]
  def change
    remove_column :shots, :location_id
  end
end
