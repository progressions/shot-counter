class DiscordStartFightJob < ApplicationJob
  queue_as :default

  def perform(fight_id, channel_id)
    fight = Fight.find(fight_id)
    discord_server_id = fight.server_id || CurrentFight.get_server_id_for_fight(fight_id)
    Rails.logger.info("DISCORD: Processing DiscordStartFightJob for fight_id: #{fight_id}, server_id: #{discord_server_id}, channel_id: #{fight.channel_id}")
    return unless discord_server_id.present? && fight.channel_id.present?

    content = FightPoster.shots(fight)
    response = $discord_bot.send_message(fight.channel_id, content)
    fight.update_column(:fight_message_id, response.id)
    Rails.logger.info("DISCORD: New message sent, fight_message_id set to: #{response.id}")
  rescue => e
    Rails.logger.error("DISCORD: Failed to send start fight message: #{e.message}, backtrace: #{e.backtrace.join("\n")}")
    fight.update_column(:fight_message_id, nil) if fight.fight_message_id.present?
  end
end
