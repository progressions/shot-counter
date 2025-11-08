class RemoveImageUrlFromTables < ActiveRecord::Migration[8.0]
  def change
    remove_column :characters, :image_url, :string
    remove_column :schticks, :image_url, :string
    remove_column :weapons, :image_url, :string
    remove_column :vehicles, :image_url, :string
  end
end
