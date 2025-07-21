class AddCampaignIdToJunctures < ActiveRecord::Migration[8.0]
  def change
    add_column :junctures, :campaign_id, :uuid
    add_index :junctures, :campaign_id
    add_foreign_key :junctures, :campaigns
  end
end
