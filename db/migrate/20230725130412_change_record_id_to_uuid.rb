class ChangeRecordIdToUuid < ActiveRecord::Migration[7.0]
  def change
    remove_column :active_storage_attachments, :record_id
    add_column :active_storage_attachments, :record_id, :uuid, null: true
  end
end
