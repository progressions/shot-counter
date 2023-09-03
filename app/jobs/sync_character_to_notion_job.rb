class SyncCharacterToNotionJob < ApplicationJob
  queue_as :default

  def perform(character_id)
    return unless Rails.env.production?

    character = Character.find(character_id)
    character.sync_to_notion
  end
end
