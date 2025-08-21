class AddPendingInvitationToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :pending_invitation_id, :uuid
    add_index :users, :pending_invitation_id
  end
end
