class CreateWeapons < ActiveRecord::Migration[7.0]
  def change
    create_table :weapons, id: :uuid do |t|
      t.references :campaign, type: :uuid, null: false, foreign_key: true
      t.string :name, null: false
      t.integer :damage, null: false
      t.integer :concealment
      t.integer :reload_value

      t.timestamps
    end
  end
end
