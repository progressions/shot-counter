class AddCampaignReferenceToCharacter < ActiveRecord::Migration[7.0]
  def change
    add_reference :characters, :campaign, type: :uuid, foreign_key: true
  end
end
