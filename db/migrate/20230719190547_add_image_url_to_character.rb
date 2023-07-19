class AddImageUrlToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :image_url, :string
  end
end
