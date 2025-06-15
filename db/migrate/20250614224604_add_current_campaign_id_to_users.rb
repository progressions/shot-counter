class AddCurrentCampaignIdToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :current_campaign_id, :uuid
    add_foreign_key :users, :campaigns, column: :current_campaign_id, primary_key: :id
  end
end
