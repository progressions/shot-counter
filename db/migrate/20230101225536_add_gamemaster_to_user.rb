class AddGamemasterToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :gamemaster, :boolean
  end
end
