class AiCharacterUpdateJob < ApplicationJob
  queue_as :default

  def perform(character_id)
    character = Character.find(character_id)
    json = AiService.extend_character(character)

    Rails.logger.info("Generated AI character JSON: #{json}")

    if json.is_a?(Hash) && json['error']
      ActionCable.server.broadcast("campaign_#{campaign.id}", { status: 'error', error: json['error'] })
      return
    end

    updated_character = AiService.merge_json_with_existing_character(json, character)
    updated_character.save!

    # Broadcast the character
    ActionCable.server.broadcast("campaign_#{campaign.id}", { status: "character_ready", character: CharacterSerializer.new(character).serializable_hash })
  rescue StandardError => e
    ActionCable.server.broadcast("campaign_#{campaign.id}", { status: "error", error: e.message })
  end
end
