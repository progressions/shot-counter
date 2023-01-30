class CreateWeapons < ActiveRecord::Migration[7.0]
  def change
    create_table :weapons, id: :uuid do |t|
      t.string :name
      t.integer :damage
      t.integer :concealment
      t.integer :reload

      t.timestamps
    end
  end
end
