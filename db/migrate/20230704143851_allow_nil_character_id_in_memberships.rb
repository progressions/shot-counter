class AllowNilCharacterIdInMemberships < ActiveRecord::Migration[7.0]
  def change
    change_column_null :memberships, :character_id, true
  end
end
