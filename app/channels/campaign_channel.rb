class CampaignChannel < ApplicationCable::Channel
  def subscribed
    campaign_id = params[:id]
    client_id = params[:client_id] || connection.connection_identifier

    # Stream from both the general campaign channel and a unique client-specific channel
    stream_from "campaign_#{campaign_id}"
    stream_from "campaign_#{campaign_id}_#{client_id}"

    Rails.logger.info "🔗 CampaignChannel: Client #{client_id} subscribed to campaign #{campaign_id}"
  end

  def unsubscribed
    campaign_id = params[:id]
    client_id = params[:client_id] || connection.connection_identifier
    Rails.logger.info "❌ CampaignChannel: Client #{client_id} unsubscribed from campaign #{campaign_id}"
  end
end
