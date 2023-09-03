class AddLastSyncedToNotionAtToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :last_synced_to_notion_at, :datetime
  end
end
