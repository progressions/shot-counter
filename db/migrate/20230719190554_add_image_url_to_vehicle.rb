class AddImageUrlToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_column :vehicles, :image_url, :string
  end
end
