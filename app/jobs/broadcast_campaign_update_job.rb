class BroadcastCampaignUpdateJob < ApplicationJob
  queue_as :default

  def perform(entity_class, entity_id)
    entity = entity_class.constantize.find(entity_id)
    
    # Clear image URL cache if this entity has images
    if entity.respond_to?(:clear_image_url_cache)
      entity.send(:clear_image_url_cache)
    end

    channel = "campaign_#{entity.campaign_id}"
    payload = { entity.class.name.underscore => "#{entity_class}Serializer".constantize.new(entity).serializable_hash }

    ActionCable.server.broadcast(channel, payload)
    ActionCable.server.broadcast(channel, { entity.class.name.downcase.pluralize => "reload" })
  end
end
