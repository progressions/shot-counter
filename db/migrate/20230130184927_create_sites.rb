class CreateSites < ActiveRecord::Migration[7.0]
  def change
    create_table :sites, id: :uuid do |t|
      t.references :character, null: false, type: :uuid, foreign_key: true
      t.string :description

      t.timestamps
    end
  end
end
