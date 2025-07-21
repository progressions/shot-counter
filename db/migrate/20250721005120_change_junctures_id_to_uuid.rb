class ChangeJuncturesIdToUuid < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")

    # Drop the default bigint id and recreate as uuid
    change_table :junctures do |t|
      t.remove :id
      t.uuid :id, default: "gen_random_uuid()", null: false, primary_key: true
    end
  end

  def down
    # Revert to bigint id
    change_table :junctures do |t|
      t.remove :id
      t.bigint :id, null: false, primary_key: true
    end

    # Reset sequence for bigint id
    execute "CREATE SEQUENCE junctures_id_seq OWNED BY junctures.id;"
    execute "ALTER TABLE junctures ALTER COLUMN id SET DEFAULT nextval('junctures_id_seq');"
  end
end
