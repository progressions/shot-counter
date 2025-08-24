class UpdateSchtickUniquenessIndex < ActiveRecord::Migration[8.0]
  def change
    # Remove old unique index on category and name only
    remove_index :schticks, name: "index_schticks_on_category_and_name"
    
    # Add new unique index on category, name, and campaign_id
    add_index :schticks, [:category, :name, :campaign_id], unique: true, name: "index_schticks_on_category_name_and_campaign"
  end
end
