class CreateSchticks < ActiveRecord::Migration[7.0]
  def change
    create_table :schticks, id: :uuid do |t|
      t.references :campaign, null: false, type: :uuid, foreign_key: true
      t.string :title, null: false
      t.string :description
      t.references :prerequisite, null: true, type: :uuid, foreign_key: { to_table: :schticks }
      t.string :category
      t.string :path

      t.index :title, unique: true

      t.timestamps
    end
  end
end
