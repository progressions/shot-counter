class CreateInvitations < ActiveRecord::Migration[7.0]
  def change
    create_table :invitations, id: :uuid do |t|
      t.references :campaign, null: false, type: :uuid, foreign_key: true

      t.timestamps
    end
  end
end
