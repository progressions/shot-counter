class AiImageCreationJob < ApplicationJob
  queue_as :default

  def perform(entity_type, entity_id, campaign_id)
    entity = entity_type.constantize.find(entity_id)

    # urls = AiService.generate_images_for_entity(entity)

    urls = ["https://imgen.x.ai/xai-imgen/xai-tmp-imgen-fecd5447-0942-484d-afe6-d69c6ee1b45d.jpeg", "https://imgen.x.ai/xai-imgen/xai-tmp-imgen-18a3d5fc-e0c7-4399-ac92-8214e9825177.jpeg", "https://imgen.x.ai/xai-imgen/xai-tmp-imgen-5f44c07d-393e-468a-ba1d-a21217fabcfa.jpeg"]
    json = urls.to_json

    # Broadcast the JSON for preview
    ActionCable.server.broadcast("campaign_#{campaign_id}", { status: 'preview_ready', json: json })
  rescue StandardError => e
    ActionCable.server.broadcast("campaign_#{campaign_id}", { status: 'error', error: e.message })
  end
end
