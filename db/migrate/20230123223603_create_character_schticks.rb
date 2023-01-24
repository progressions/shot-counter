class CreateCharacterSchticks < ActiveRecord::Migration[7.0]
  def change
    create_table :character_schticks do |t|
      t.references :character, null: false, type: :uuid, foreign_key: true
      t.references :schtick, null: false, type: :uuid, foreign_key: true

      t.index ["character_id", "schtick_id"], name: "index_character_id_on_schtick_id", unique: true

      t.timestamps
    end
  end
end
