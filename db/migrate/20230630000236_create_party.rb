class CreateParty < ActiveRecord::Migration[7.0]
  def change
    create_table :parties, id: :uuid do |t|
      t.string :name
      t.string :description
      t.references :campaign, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
