class BroadcastCampaignReloadJob < ApplicationJob
  queue_as :default

  def perform(entity_class, campaign_id)
    channel = "campaign_#{campaign_id}"
    payload = { entity_class.underscore.pluralize => "reload" }

    puts "🔄 BroadcastCampaignReloadJob: Broadcasting to #{channel} with payload: #{payload.inspect}"
    result = ActionCable.server.broadcast(channel, payload)
    puts "🔄 BroadcastCampaignReloadJob: Broadcast result: #{result.inspect}"
  end
end
