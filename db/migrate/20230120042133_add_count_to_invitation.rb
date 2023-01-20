class AddCountToInvitation < ActiveRecord::Migration[7.0]
  def change
    add_column :invitations, :maximum_count, :integer
    add_column :invitations, :remaining_count, :integer
    change_column_null :invitations, :email, true
  end
end
