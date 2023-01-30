class CreateWeapons < ActiveRecord::Migration[7.0]
  def change
    create_table :weapons, id: :uuid do |t|
      t.references :campaign, type: :uuid, null: false, foreign_key: true
      t.string :name
      t.integer :damage
      t.integer :concealment
      t.integer :reload

      t.timestamps
    end
  end
end
