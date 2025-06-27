module SlashShowFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:show, "Show current fight") do |cmd|
    cmd.boolean(:url, "Show url")
  end

  Bot.application_command(:show) do |event|
    unless event.channel_id.present?
      event.respond(content: "Error: Discord channel ID is missing.", ephemeral: true)
      next
    end

    data = CurrentFight.get(server_id: event.server_id)
    fight = data[:fight]

    if fight
      fight.update(server_id: event.server_id, channel_id: event.channel_id) unless fight.server_id == event.server_id.to_s && fight.channel_id == event.channel_id
      event.respond(content: "OK", ephemeral: true)

      if fight.fight_message_id.present?
        DiscordNotificationJob.perform_later(fight.id)
      else
        DiscordStartFightJob.perform_later(fight.id, fight.channel_id)
      end
    else
      event.respond(content: "There is no current fight.")
    end
  rescue => e
    Rails.logger.error("ShowFight DISCORD: #{e.message}")
    fight.update_column(:fight_message_id, nil) if fight&.fight_message_id.present?
  end
end
