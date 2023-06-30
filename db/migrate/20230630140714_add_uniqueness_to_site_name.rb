class AddUniquenessToSiteName < ActiveRecord::Migration[7.0]
  def change
    add_index :sites, [:campaign_id, :name], unique: true
  end
end
