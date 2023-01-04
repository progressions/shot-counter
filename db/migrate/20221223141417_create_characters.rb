class CreateCharacters < ActiveRecord::Migration[7.0]
  def change
    create_table :characters do |t|
      t.string :name, null: false
      t.references :fight, type: :uuid, null: false, foreign_key: true
      t.integer :current_shot
      t.integer :defense
      t.integer :impairments

      t.timestamps
    end
  end
end
