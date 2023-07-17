class AddDriverIdToShots < ActiveRecord::Migration[7.0]
  def change
    add_reference :shots, :driver, null: true, type: :uuid, foreign_key: { to_table: :characters }
  end
end

