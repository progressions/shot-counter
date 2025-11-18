module Broadcastable
  extend ActiveSupport::Concern

  included do
    after_commit :broadcast_campaign_update, on: [:create, :update]
    after_destroy :broadcast_reload
    after_create :broadcast_reload
    after_destroy :broadcast_reload
  end

  def broadcast_campaign_update
    return if Thread.current[:disable_broadcasts]
    Rails.logger.info "🔄 Broadcastable: #{self.class.name} (ID: #{id}) triggering campaign update broadcast"
    BroadcastCampaignUpdateJob.perform_later(self.class.name, id)
  end

  def broadcast_reload
    return if Thread.current[:disable_broadcasts]
    Rails.logger.info "🔄 Broadcastable: #{self.class.name} (ID: #{id}) triggering reload broadcast for campaign_id: #{self.campaign_id}"
    BroadcastCampaignReloadJob.perform_later(self.class.name, self.campaign_id)
  end

  def entity_class=(anything=nil)
  end
end
