class AddActiveToFaction < ActiveRecord::Migration[8.0]
  def change
    add_column :factions, :active, :boolean, default: true
  end
end
