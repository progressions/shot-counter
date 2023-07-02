class AddCampaignReferenceToFaction < ActiveRecord::Migration[7.0]
  def change
    add_reference :factions, :campaign, null: false, foreign_key: true, type: :uuid
  end
end
