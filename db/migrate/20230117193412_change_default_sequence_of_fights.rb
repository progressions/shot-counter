class ChangeDefaultSequenceOfFights < ActiveRecord::Migration[7.0]
  def change
    change_column_default :fights, :sequence, 0
  end
end
