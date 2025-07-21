class MakeFactionIdNullableOnJunctures < ActiveRecord::Migration[8.0]
  def change
    change_column_null :junctures, :faction_id, true
  end
end
