class BroadcastCampaignReloadJob < ApplicationJob
  queue_as :default

  def perform(entity_class, campaign_id)
    channel = "campaign_#{campaign_id}"
    payload = { entity_class.underscore.pluralize => "reload" }

    result = ActionCable.server.broadcast(channel, payload)
  end
end
