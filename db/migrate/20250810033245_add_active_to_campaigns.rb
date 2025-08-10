class AddActiveToCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :campaigns, :active, :boolean, default: true, null: false
  end
end
