class CreateJunctures < ActiveRecord::Migration[8.0]
  def change
    create_table :junctures do |t|
      t.string :name
      t.string :description
      t.boolean :active
      t.references :faction, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
