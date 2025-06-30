class AddActiveToFaction < ActiveRecord::Migration[8.0]
  def change
    add_column :factions, :active, :boolean
  end
end
