class ChangeLocationsShotId < ActiveRecord::Migration[7.0]
  def change
    change_column_null :locations, :shot_id, true
  end
end
