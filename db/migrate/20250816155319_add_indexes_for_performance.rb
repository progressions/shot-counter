class AddIndexesForPerformance < ActiveRecord::Migration[8.0]
  def change
    add_index :campaign_memberships, [:campaign_id, :user_id], name: "index_campaign_memberships_on_campaign_id_and_user_id"
  end
end
