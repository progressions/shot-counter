class AddNameIndexToUser < ActiveRecord::Migration[8.0]
  def change
    add_index :users, "LOWER(name)", name: "index_users_on_lower_name"
  end
end
