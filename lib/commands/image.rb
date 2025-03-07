module ImageCommands
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:image, "Show character image") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:image) do |event|
    campaign = CurrentCampaign.get(server_id: event.server_id)
    if (!campaign)
      event.respond(content: "No campaign set")
      return
    end

    characters = campaign
      .characters
      .active

    character = characters.find_by(name: event.options["name"])
    if !character
      event.respond(content: "Character not found")
    else
      event.respond(content: character.image_url)
    end
  end
end
