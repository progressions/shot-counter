module SlashStartFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:start, "Start a fight")  # No options needed

  Bot.application_command(:start) do |event|
    unless event.channel_id.present?
      event.respond(content: "Error: Discord channel ID is missing.", ephemeral: true)
      next
    end

    campaign = CurrentCampaign.get(server_id: event.server_id)
    active_fights = campaign.fights.active.limit(25)  # Limit to 25 for select menu max

    if active_fights.empty?
      event.respond(content: "No active fights found!")
      next
    end

    # Build select menu options as hashes
    options = active_fights.map do |fight|
      {
        label: fight.name[0..99],  # Label max 100 chars
        value: fight.id.to_s  # Use ID as value for uniqueness
      }
    end

    # Build the component hash
    components = [
      {
        type: 1,  # ActionRow
        components: [
          {
            type: 3,  # SelectMenu
            custom_id: "start_fight_select",
            placeholder: "Select a fight to start",
            min_values: 1,
            max_values: 1,
            options: options
          }
        ]
      }
    ]

    event.respond(content: "Choose a fight to start:", components: components)
  rescue => e
    Rails.logger.error("DISCORD: Failed to initiate fight selection: #{e.message}")
    event.respond(content: "Error: #{e.message}", ephemeral: true)
  end

  # Handle select menu interactions (moved here for co-location)
  Bot.select_menu(custom_id: "start_fight_select") do |event|
    Rails.logger.info("DISCORD: #{event.values.inspect}")
    fight_id = event.values.first
    fight = Fight.find_by(id: fight_id)

    unless fight
      event.respond(content: "Fight not found!", ephemeral: true)
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

    # Respond to the selection
    event.respond(content: "Starting fight: #{fight.name}")

    # Optional: Edit the original message to remove the menu
    event.message.edit(content: "Fight selected: #{fight.name}", components: [])
  rescue => e
    Rails.logger.error("DISCORD: Failed to start fight from selection: #{e.message}")
    fight.update_column(:fight_message_id, nil) if fight&.fight_message_id.present?
    event.respond(content: "Error starting fight: #{e.message}", ephemeral: true)
  end
end
