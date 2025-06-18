# app/jobs/discord_show_fight_job.rb
class DiscordShowFightJob < ApplicationJob
  queue_as :default

  def perform(fight_id, channel_id, message_id)
    fight = Fight.find(fight_id)
    discord_server_id = fight.server_id || CurrentFight.get_server_id_for_fight(fight_id)
    return unless discord_server_id.present? && channel_id.present?

    content = FightPoster.shots(fight)
    $discord_bot.edit_message(channel_id, message_id, content)
  rescue => e
    Rails.logger.error("DISCORD: Failed to edit show fight message: #{e.message}, backtrace: #{e.backtrace.join("\n")}")
    fight.update_column(:fight_message_id, nil) if fight.fight_message_id.present?
  end
end
