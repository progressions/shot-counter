class BroadcastEncounterUpdateJob < ApplicationJob
  queue_as :default

  def perform(entity_id)
    Rails.logger.info "🔄 WEBSOCKET: BroadcastEncounterUpdateJob performing for fight #{entity_id}"
    entity = Fight.find(entity_id)

    channel = "campaign_#{entity.campaign_id}"
    payload = { encounter: EncounterSerializer.new(entity).serializable_hash }

    Rails.logger.info "🔄 WEBSOCKET: Broadcasting to channel '#{channel}' with encounter data"
    result = ActionCable.server.broadcast(channel, payload)
    Rails.logger.info "🔄 WEBSOCKET: Broadcast result: #{result} subscribers received the update"
  end
end
