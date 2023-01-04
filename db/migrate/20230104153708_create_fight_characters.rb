class CreateFightCharacters < ActiveRecord::Migration[7.0]
  def change
    create_table :fight_characters, id: :uuid do |t|
      t.references :character, type: :uuid, null: false, foreign_key: true
      t.references :fight, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
