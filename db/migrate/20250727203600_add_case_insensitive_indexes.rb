class AddCaseInsensitiveIndexes < ActiveRecord::Migration[8.0]
  def change
    add_index :fights, "LOWER(name)", name: "index_fights_on_lower_name"
    add_index :sites, "LOWER(name)", name: "index_sites_on_lower_name"
    add_index :parties, "LOWER(name)", name: "index_parties_on_lower_name"
    add_index :schticks, "LOWER(name)", name: "index_schticks_on_lower_name"
    add_index :vehicles, "LOWER(name)", name: "index_vehicles_on_lower_name"
    add_index :weapons, "LOWER(name)", name: "index_weapons_on_lower_name"
    add_index :campaigns, "LOWER(name)", name: "index_campaigns_on_lower_name"
    add_index :factions, "LOWER(name)", name: "index_factions_on_lower_name"
    add_index :junctures, "LOWER(name)", name: "index_junctures_on_lower_name"
  end
end
