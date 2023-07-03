class AddDescriptionToFight < ActiveRecord::Migration[7.0]
  def change
    add_column :fights, :description, :text
  end
end
