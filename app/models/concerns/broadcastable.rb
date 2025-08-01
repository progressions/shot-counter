module Broadcastable
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_campaign_update, on: [:create, :update]
    after_destroy :broadcast_reload
    after_create :broadcast_reload
    after_destroy :broadcast_reload
  end

  def broadcast_campaign_update
    BroadcastCampaignUpdateJob.perform_later(self.class.name, id)
  end

  def broadcast_reload
    BroadcastCampaignReloadJob.perform_later(self.class.name, campaign_id)
  end
end
