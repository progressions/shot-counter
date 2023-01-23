class CreateSchticks < ActiveRecord::Migration[7.0]
  def change
    create_table :schticks do |t|
      t.string :title, null: false
      t.string :description
      t.references :schtick, null: false, foreign_key: true
      t.string :archetype, null: false
      t.string :category

      t.timestamps
    end
  end
end
