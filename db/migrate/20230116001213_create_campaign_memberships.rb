class CreateCampaignMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :campaign_memberships, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :campaign, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
