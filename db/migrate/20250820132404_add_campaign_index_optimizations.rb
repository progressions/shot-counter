class AddCampaignIndexOptimizations < ActiveRecord::Migration[8.0]
  def change
    # Campaigns table optimizations
    add_index :campaigns, [:active, :created_at], name: 'index_campaigns_on_active_and_created_at'
    
    # Characters table optimizations for campaigns index eager loading
    add_index :characters, [:campaign_id, :active], name: 'index_characters_on_campaign_id_and_active'
    add_index :characters, [:campaign_id, :active, :created_at], name: 'index_characters_on_campaign_active_created'
    
    # Vehicles table optimizations for campaigns index eager loading
    add_index :vehicles, [:campaign_id, :active], name: 'index_vehicles_on_campaign_id_and_active'
    add_index :vehicles, [:campaign_id, :active, :created_at], name: 'index_vehicles_on_campaign_active_created'
    
    # Campaign memberships optimization for user filtering
    add_index :campaign_memberships, [:user_id, :created_at], name: 'index_campaign_memberships_on_user_and_created'
  end
end
