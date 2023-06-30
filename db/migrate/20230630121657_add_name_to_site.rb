class AddNameToSite < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :name, :string
  end
end
