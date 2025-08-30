class CampaignSeederJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    Rails.logger.info "[CampaignSeederJob] STARTING - Received campaign_id: #{campaign_id}"
    
    campaign = Campaign.find(campaign_id)
    Rails.logger.info "[CampaignSeederJob] Found campaign: #{campaign.name} (ID: #{campaign_id})"
    
    Rails.logger.info "Starting campaign seeding job for campaign #{campaign.name} (ID: #{campaign_id})"
    
    success = CampaignSeederService.seed_campaign(campaign)
    
    if success
      Rails.logger.info "[CampaignSeederJob] SUCCESS - Campaign seeding job completed successfully for campaign #{campaign.name}"
      Rails.logger.info "Campaign seeding job completed successfully for campaign #{campaign.name}"
    else
      Rails.logger.error "[CampaignSeederJob] FAILURE - Campaign seeding job failed for campaign #{campaign.name}"
      Rails.logger.error "Campaign seeding job failed for campaign #{campaign.name}"
    end
    
    success
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error "Campaign seeding job failed - campaign not found: #{campaign_id}"
    false
  rescue StandardError => e
    Rails.logger.error "Campaign seeding job failed with error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end