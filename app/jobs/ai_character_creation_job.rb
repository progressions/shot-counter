class AiCharacterCreationJob < ApplicationJob
  queue_as :default

  def perform(description, campaign_id)
    campaign = Campaign.find(campaign_id)
    json = AiCharacterService.generate_character(description, campaign)

    Rails.logger.info("Generated AI character JSON: #{json}")

    if json.is_a?(Hash) && json['error']
      ActionCable.server.broadcast("campaign_#{campaign.id}", { status: 'error', error: json['error'] })
      return
    end

    # Broadcast the JSON for preview
    ActionCable.server.broadcast("campaign_#{campaign.id}", { status: 'preview_ready', json: json })
  rescue StandardError => e
    ActionCable.server.broadcast("campaign_#{campaign.id}", { status: 'error', error: e.message })
  end
end
