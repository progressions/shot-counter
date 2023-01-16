class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :campaign, null: false, type: :uuid, foreign_key: true
      t.references :user, null: false, type: :uuid, foreign_key: true
      t.string :email, null: true
      t.references :pending_user, null: true, type: :uuid, foreign_key: { to_table: :users }

      t.timestamps

      t.index ["campaign_id", "email"], name: "index_invitations_on_campaign_email", unique: true
      t.index ["campaign_id", "pending_user_id"], name: "index_invitations_on_campaign_and_pending_user", unique: true
    end
  end
end
