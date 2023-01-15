class AddCampaignReferenceToVehicle < ActiveRecord::Migration[7.0]
  def change
    add_reference :vehicles, :campaign, type: :uuid, foreign_key: true
  end
end
