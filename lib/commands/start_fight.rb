module SlashStartFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:start, "Start a fight") do |cmd|
    cmd.string(:name, "Fight name")
  end

  Bot.application_command(:start) do |event|
    unless event.channel_id.present?
      event.respond(content: "Error: Discord channel ID is missing.", ephemeral: true)
      next
    end

    campaign = CurrentCampaign.get(server_id: event.server_id)
    fight_name = event.options["name"]
    fight = campaign
      .fights
      .active
      .where("name ILIKE ?", fight_name.downcase)
      .first

    if !fight
      event.respond(content: "Couldn't find that fight!")
      next
    end

    # Update Fight with server_id, channel_id, and clear fight_message_id
    fight.update(
      server_id: event.server_id,
      channel_id: event.channel_id,
      fight_message_id: nil
    )

    # Set the current fight
    CurrentFight.set(server_id: event.server_id, fight: fight)

    # Enqueue job to send initial fight message
    DiscordStartFightJob.perform_later(fight.id, event.channel_id)

    event.respond(content: "Starting fight: #{fight.name}")
  rescue => e
    Rails.logger.error("DISCORD: Failed to start fight: #{e.message}")
    fight.update_column(:fight_message_id, nil) if fight&.fight_message_id.present?
    event.respond(content: "Error starting fight: #{e.message}", ephemeral: true)
  end
end
