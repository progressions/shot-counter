module SlashHaltFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:halt, "Stop the current fight") do |cmd|
  end

  Bot.application_command(:halt) do |event|
    unless event.channel_id.present?
      event.respond(content: "Error: Discord channel ID is missing.", ephemeral: true)
      next
    end

    data = CurrentFight.get(server_id: event.server_id)
    fight = data[:fight]

    if fight.nil?
      event.respond(content: "There is no current fight.")
      next
    end

    fight.update(server_id: nil, channel_id: nil, fight_message_id: nil)
    CurrentFight.set(server_id: event.server_id, fight: nil)
    event.respond(content: "Stopping fight: #{fight.name}")

    if fight.fight_message_id.present? && fight.channel_id.present?
      DiscordHaltFightJob.perform_later(fight.id, fight.channel_id, fight.fight_message_id)
    end
  rescue => e
    Rails.logger.error("DISCORD: Failed to halt fight: #{e.message}")
    event.respond(content: "Error stopping fight: #{e.message}", ephemeral: true)
  end
end
