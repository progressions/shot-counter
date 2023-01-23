class CreateSchticks < ActiveRecord::Migration[7.0]
  def change
    create_table :schticks, id: :uuid do |t|
      t.string :title, null: false
      t.string :description
      t.references :schtick, null: true, type: :uuid, foreign_key: true
      t.string :category
      t.string :path

      t.timestamps
    end
  end
end
