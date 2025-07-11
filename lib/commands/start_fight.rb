module SlashStartFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:start, "Start a fight") do |cmd|
    cmd.string(:name, "Fight name", required: true, autocomplete: true)
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
      .find_by(name: fight_name)  # Exact match since autocomplete provides full name

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
    DiscordNotificationJob.perform_later(fight.id)

    event.respond(content: "Starting fight: #{fight.name}")
  rescue => e
    Rails.logger.error("DISCORD: Failed to start fight: #{e.message}")
    fight.update_column(:fight_message_id, nil) if fight&.fight_message_id.present?
    event.respond(content: "Error starting fight: #{e.message}", ephemeral: true)
  end

  # Autocomplete handler using the specific autocomplete event
  Bot.autocomplete do |event|
    Rails.logger.info("Autocomplete event triggered")  # Debug log to check if handler fires

    next unless event.command_name == :start
    next unless event.focused == "name"

    campaign = CurrentCampaign.get(server_id: event.server_id)
    partial_name = event.options["name"].downcase
    Rails.logger.info("Partial name: #{partial_name}")  # Debug log

    fights = campaign.fights.active.where("name ILIKE ?", "%#{partial_name}%").limit(25)

    choices = fights.map do |fight|
      { name: fight.name, value: fight.name }
    end

    event.respond(choices: choices)
  end
end
