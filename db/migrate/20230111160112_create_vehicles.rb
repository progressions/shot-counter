class CreateVehicles < ActiveRecord::Migration[7.0]
  def change
    create_table :vehicles, id: :uuid do |t|
      t.string "name", null: false
      t.jsonb "action_values", null: false

      t.timestamps
    end
  end
end
