class CreateShots < ActiveRecord::Migration[7.0]
  def change
    create_table :shots, id: :uuid do |t|
      t.references :fight, null: false, foreign_key: true, type: :uuid
      t.references :character, null: true, foreign_key: true, type: :uuid
      t.references :vehicle, null: true, foreign_key: true, type: :uuid
      t.integer :shot
      t.string :position

      t.timestamps
    end
  end
end
