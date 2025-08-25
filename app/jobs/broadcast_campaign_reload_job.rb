class BroadcastCampaignReloadJob < ApplicationJob
  queue_as :default

  def perform(entity_class, campaign_id)
    channel = "campaign_#{campaign_id}"
    payload = { entity_class.underscore.pluralize => "reload" }

    Rails.logger.info "🔄 BroadcastCampaignReloadJob: Broadcasting to #{channel} with payload: #{payload.inspect}"
    result = ActionCable.server.broadcast(channel, payload)
    Rails.logger.info "🔄 BroadcastCampaignReloadJob: Broadcast result: #{result.inspect}"
  end
end
