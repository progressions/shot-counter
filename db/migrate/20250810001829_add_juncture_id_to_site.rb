class AddJunctureIdToSite < ActiveRecord::Migration[8.0]
  def change
    add_reference :sites, :juncture, type: :uuid, foreign_key: { to_table: :junctures }
  end
end
