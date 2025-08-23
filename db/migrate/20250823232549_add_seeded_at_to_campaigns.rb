class AddSeededAtToCampaigns < ActiveRecord::Migration[8.0]
  def change
    add_column :campaigns, :seeded_at, :datetime
  end
end
