class ChangeUniqueTitleOnSchtick < ActiveRecord::Migration[7.0]
  def change
    remove_index :schticks, :title
    add_index :schticks, [:category, :title], unique: true
  end
end
