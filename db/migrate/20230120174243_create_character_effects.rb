class CreateCharacterEffects < ActiveRecord::Migration[7.0]
  def change
    create_table :character_effects, id: :uuid do |t|
      t.references :character, null: false, type: :uuid, foreign_key: true
      t.references :fight, null: false, type: :uuid, foreign_key: true
      t.string :title, null: false
      t.string :description

      t.timestamps
    end
  end
end
