class AddFirstCampaignActivatedAtToOnboardingProgresses < ActiveRecord::Migration[8.0]
  def change
    add_column :onboarding_progresses, :first_campaign_activated_at, :datetime
  end
end
