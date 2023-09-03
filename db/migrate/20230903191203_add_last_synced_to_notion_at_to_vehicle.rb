class AddLastSyncedToNotionAtToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :last_synced_to_notion_at, :datetime
  end
end
