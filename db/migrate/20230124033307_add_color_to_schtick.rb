class AddColorToSchtick < ActiveRecord::Migration[7.0]
  def change
    add_column :schticks, :color, :string
    add_column :schticks, :image_url, :string
  end
end
