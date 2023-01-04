class RemoveCurrentShotFromCharacter < ActiveRecord::Migration[7.0]
  def change
    remove_column :characters, :current_shot
  end
end
