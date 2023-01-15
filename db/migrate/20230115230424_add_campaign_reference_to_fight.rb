class AddCampaignReferenceToFight < ActiveRecord::Migration[7.0]
  def change
    add_reference :fights, :campaign, type: :uuid, foreign_key: true
  end
end
