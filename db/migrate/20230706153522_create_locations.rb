class CreateLocations < ActiveRecord::Migration[7.0]
  def change
    create_table :locations, id: :uuid do |t|
      t.string :name, null: false
      t.references :shot, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
