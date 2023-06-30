class RemoveNullConstraintFromSites < ActiveRecord::Migration[7.0]
  def change
    change_column_null :sites, :character_id, true
  end
end
