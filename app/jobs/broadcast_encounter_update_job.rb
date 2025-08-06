class BroadcastEncounterUpdateJob < ApplicationJob
  queue_as :default

  def perform(entity_id)
    entity = Fight.find(entity_id)

    channel = "campaign_#{entity.campaign_id}"
    payload = { encounter: EncounterSerializer.new(entity).serializable_hash }

    ActionCable.server.broadcast(channel, payload)
  end
end
