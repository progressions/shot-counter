class AddImageUrlToWeapon < ActiveRecord::Migration[7.0]
  def change
    add_column :weapons, :image_url, :string
  end
end
