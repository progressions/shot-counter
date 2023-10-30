class AddDrivingIdToShots < ActiveRecord::Migration[7.0]
  def change
    add_reference :shots, :driving, null: true, type: :uuid, foreign_key: { to_table: :vehicles }
  end
end
