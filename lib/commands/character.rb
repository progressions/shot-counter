module Roll
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:characters, "List characters") do |cmd|
  end

  Bot.application_command(:characters) do |event|
    campaign = CurrentCampaign.get(event.server_id)
    if (!campaign)
      event.respond(content: "No campaign set")
    else
      characters = campaign
        .characters
        .active
        .by_type("PC")

      if characters.empty?
        event.respond(content: "No characters")
      else
        event.respond(content: characters.map(&:name).join("\n"))
      end
    end
  end

  Bot.register_application_command(:character, "Use character") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:character) do |event|
    campaign = CurrentCampaign.get(event.server_id)
    if (!campaign)
      event.respond(content: "No campaign set")
      return
    end

    characters = campaign
      .characters
      .active
      .by_type("PC")

    character = characters.find_by(name: event.options["name"])
    if !character
      event.respond(content: "Character not found")
    else
      CharacterPoster.set_character(event.user.id, character.id)
      event.respond(content: "Using character: #{character.name}")
    end
  end

  Bot.register_application_command(:stats, "List character stats") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:stats) do |event|
    campaign = CurrentCampaign.get(event.server_id)
    if (!campaign)
      event.respond(content: "No campaign set")
    else
      if event.options["name"]
        if (character = campaign.characters.where(active: true).find_by(name: event.options["name"]))
          message = CharacterPoster.show(character)
          Rails.logger.info("Message: #{message}")
          Rails.logger.info("Message length: #{message.length}")
          event.respond(content: message)
        else
          event.respond(content: "Character not found")
        end
      else
        if character = CharacterPoster.get_character(event.user.id)
          message = CharacterPoster.show(character)
          event.respond(content: message)
        else
          event.respond(content: "Character not found")
        end
      end
    end
  end
end
