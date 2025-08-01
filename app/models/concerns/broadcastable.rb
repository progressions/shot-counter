module Broadcastable
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_campaign_update, on: [:create, :update]
  end

  def broadcast_campaign_update
    BroadcastCampaignUpdateJob.perform_later(self.class.name, id)
  end
end
