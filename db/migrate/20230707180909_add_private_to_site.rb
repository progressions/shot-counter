class AddPrivateToSite < ActiveRecord::Migration[7.0]
  def change
    add_column :sites, :secret, :boolean, default: false
  end
end
