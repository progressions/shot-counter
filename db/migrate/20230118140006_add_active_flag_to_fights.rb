class AddActiveFlagToFights < ActiveRecord::Migration[7.0]
  def change
    add_column :fights, :active, :boolean, null: false, default: true
  end
end
