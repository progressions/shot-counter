class RemoveTitles < ActiveRecord::Migration[7.0]
  def change
    Campaign.find_each do |campaign|
      campaign.update(name: campaign.title)
    end

    remove_column :campaigns, :title
  rescue StandardError
  end
end
