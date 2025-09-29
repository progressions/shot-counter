class RemoveUniqueIndexFromMemberships < ActiveRecord::Migration[8.0]
  INDEX_NAME = "memberships_party_id_character_id_index"

  def up
    execute <<~SQL
      ALTER TABLE memberships
      DROP CONSTRAINT IF EXISTS #{INDEX_NAME};
    SQL

    if index_exists?(:memberships, [:party_id, :character_id], name: INDEX_NAME)
      remove_index :memberships, column: [:party_id, :character_id], name: INDEX_NAME
    end
  end

  def down
    execute <<~SQL
      ALTER TABLE memberships
      ADD CONSTRAINT #{INDEX_NAME}
      UNIQUE (party_id, character_id);
    SQL
  end
end
