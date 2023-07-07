class AddPrivateToParty < ActiveRecord::Migration[7.0]
  def change
    add_column :parties, :private, :boolean, default: false
  end
end
