class CampaignChannel < ApplicationCable::Channel
  def subscribed
    stream_from "campaign_#{params[:id]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
