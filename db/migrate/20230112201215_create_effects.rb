class CreateEffects < ActiveRecord::Migration[7.0]
  def change
    create_table :effects, id: :uuid do |t|
      t.references :fight, type: :uuid, null: true, foreign_key: true
      t.references :user, type: :uuid, null: true, foreign_key: true
      t.integer :start_sequence
      t.integer :end_sequence
      t.integer :start_shot
      t.integer :end_shot
      t.string :severity
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
