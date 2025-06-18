# app/jobs/discord_notification_job.rb
class DiscordNotificationJob < ApplicationJob
  queue_as :default

  def perform(fight_id)
    fight = Fight.find(fight_id)
    discord_server_id = fight.server_id || CurrentFight.get_server_id_for_fight(fight_id)
    return unless discord_server_id.present? && fight.channel_id.present?

    content = FightPoster.shots(fight)

    begin
      channel = $discord_bot.channel(fight.channel_id)
      message = channel.message(fight.fight_message_id)
      message.edit(content) if message.present?
      # fight.update_column(:fight_message_id, response.id)
    rescue Discordrb::Errors::UnknownMessage
      response = $discord_bot.send_message(fight.channel_id, content)
      fight.update_column(:fight_message_id, response.id)
    rescue => e
      fight.update_column(:fight_message_id, nil) if fight.fight_message_id.present? && e.is_a?(Discordrb::Errors::UnknownMessage)

      response = $discord_bot.send_message(fight.channel_id, content)
      fight.update_column(:fight_message_id, response.id)
    end
  end
end
