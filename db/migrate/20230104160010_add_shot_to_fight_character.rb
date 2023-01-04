class AddShotToFightCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :fight_characters, :shot, :integer
  end
end
