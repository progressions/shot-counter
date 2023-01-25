class AddBonusToSchtick < ActiveRecord::Migration[7.0]
  def change
    add_column :schticks, :bonus, :boolean
  end
end
