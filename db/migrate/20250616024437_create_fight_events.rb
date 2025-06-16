class CreateFightEvents < ActiveRecord::Migration[8.0]
  def change
    create_table :fight_events, id: :uuid do |t|
      t.references :fight, null: false, foreign_key: true, type: :uuid
      t.string :event_type
      t.string :description
      t.jsonb :details, default: {}

      t.timestamps
    end
  end
end
