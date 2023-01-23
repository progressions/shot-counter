class CreateCharacterSchticks < ActiveRecord::Migration[7.0]
  def change
    create_table :character_schticks do |t|
      t.references :character, null: false, type: :uuid, foreign_key: true
      t.references :schtick, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
