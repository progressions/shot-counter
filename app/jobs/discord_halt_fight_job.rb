# app/jobs/discord_halt_fight_job.rb
class DiscordHaltFightJob < ApplicationJob
  queue_as :default

  def perform(fight_id, channel_id, message_id)
    fight = Fight.find(fight_id)
    return unless channel_id.present?

    $discord_bot.edit_message(channel_id, message_id, "Fight stopped: #{fight.name}")
  rescue => e
    Rails.logger.error("DISCORD: Failed to edit stopped fight message: #{e.message}, backtrace: #{e.backtrace.join("\n")}")
    fight.update_column(:fight_message_id, nil) if fight.fight_message_id.present?
  end
end
