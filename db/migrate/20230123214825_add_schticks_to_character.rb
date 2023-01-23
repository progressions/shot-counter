class AddSchticksToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_column :characters, :schticks, :jsonb, default: []
  end
end
