class BroadcastCampaignUpdateJob < ApplicationJob
  queue_as :default

  def perform(entity_class, entity_id)
    Rails.logger.info "🔄 WEBSOCKET: Broadcasting update for #{entity_class} ID #{entity_id}"

    entity = entity_class.constantize.find(entity_id)

    # Clear image URL cache if this entity has images
    if entity.respond_to?(:clear_image_url_cache)
      entity.send(:clear_image_url_cache)
    end

    channel = "campaign_#{entity.campaign_id}"
    Rails.logger.info "🔄 WEBSOCKET: Broadcasting to channel #{channel}"

    begin
      payload = { entity.class.name.underscore => "#{entity_class}Serializer".constantize.new(entity).serializable_hash }
      Rails.logger.info "🔄 WEBSOCKET: Payload created successfully"

      result1 = ActionCable.server.broadcast(channel, payload)
      result2 = ActionCable.server.broadcast(channel, { entity.class.name.downcase.pluralize => "reload" })

      Rails.logger.info "🔄 WEBSOCKET: Broadcast results: #{result1} subscribers for data, #{result2} subscribers for reload"
    rescue => e
      Rails.logger.error "🔄 WEBSOCKET ERROR: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.first(3).join("\n")
    end
  end
end
