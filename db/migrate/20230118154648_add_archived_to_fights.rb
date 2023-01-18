class AddArchivedToFights < ActiveRecord::Migration[7.0]
  def change
    add_column :fights, :archived, :boolean, null: false, default: false
  end
end
