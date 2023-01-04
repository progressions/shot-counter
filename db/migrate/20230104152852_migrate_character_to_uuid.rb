class MigrateCharacterToUuid < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :uuid, :uuid, null: false, default: -> { "gen_random_uuid()" }
    remove_column :characters, :id
    rename_column :characters, :uuid, :id
    execute "ALTER TABLE characters    ADD PRIMARY KEY (id);"
    add_index :characters,    :created_at
  end
end
