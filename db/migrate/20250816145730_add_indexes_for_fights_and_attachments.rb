class AddIndexesForFightsAndAttachments < ActiveRecord::Migration[8.0]
  def change
    add_index :fights, [:campaign_id, :active], name: "index_fights_on_campaign_id_and_active"
    add_index :active_storage_attachments, [:record_type, :name, :record_id], name: "index_active_storage_attachments_on_record_type_name_id"
  end
end
