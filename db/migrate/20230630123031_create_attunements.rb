class CreateAttunements < ActiveRecord::Migration[7.0]
  def change
    create_table :attunements, type: :uuid do |t|
      t.references :character, null: false, foreign_key: true, type: :uuid
      t.references :site, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
