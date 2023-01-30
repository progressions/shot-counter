class CreateCarries < ActiveRecord::Migration[7.0]
  def change
    create_table :carries, id: :uuid do |t|
      t.references :character, null: false, type: :uuid, foreign_key: true
      t.references :weapon, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
