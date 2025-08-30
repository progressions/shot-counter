class CampaignSeederJob < ApplicationJob
  queue_as :default
  
  # Increase retry attempts for network/connection issues
  retry_on ActiveRecord::StatementInvalid, wait: 5.seconds, attempts: 10
  retry_on ActiveRecord::ConnectionNotEstablished, wait: 5.seconds, attempts: 10
  
  # Don't retry on data integrity issues - these need manual intervention
  discard_on ActiveRecord::RecordNotUnique do |job, error|
    if error.message.include?("active_storage_blobs_pkey") || error.message.include?("active_storage_attachments_pkey")
      Rails.logger.error "[CRITICAL] Campaign seeding failed due to Active Storage ID conflict!"
      campaign_id = job.arguments.first
      campaign = Campaign.find_by(id: campaign_id)
      AdminMailer.blob_sequence_error(campaign, error.message).deliver_later if campaign
    end
  end

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
  rescue ActiveRecord::RecordNotUnique => e
    if e.message.include?("active_storage_blobs_pkey")
      Rails.logger.error "[CRITICAL] Campaign seeding failed due to Active Storage blob ID conflict!"
      Rails.logger.error "This requires manual intervention: run 'rails db:fix_blob_sequence' in production"
      Rails.logger.error "Error: #{e.message}"
      
      # Send notification email to admin
      begin
        campaign = Campaign.find_by(id: campaign_id)
        AdminMailer.blob_sequence_error(campaign, e.message).deliver_later if campaign
      rescue => mail_error
        Rails.logger.error "Failed to send notification email: #{mail_error.message}"
      end
    end
    false
  rescue StandardError => e
    Rails.logger.error "Campaign seeding job failed with error: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
    false
  end
end