class AddCampaignReferenceToSites < ActiveRecord::Migration[7.0]
  def change
    add_reference :sites, :campaign, null: true, foreign_key: true, type: :uuid
  end
end
