module Roll
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:character, "Use character") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:character) do |event|
    campaign = CurrentCampaign.get(event.server.id)
    if (!campaign)
      event.respond(content: "No campaign set")
      return
    end

    character = campaign.characters.find_by(name: event.options["name"])
    CharacterPoster.set_character(event.user.id, character.id)
    event.respond(content: "Using character: #{character.name}")
  end

  Bot.register_application_command(:stats, "List character stats") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:stats) do |event|
    campaign = CurrentCampaign.get(event.server.id)
    if (!campaign)
      event.respond(content: "No campaign set")
      return
    end

    if event.options["name"]
      if (character = campaign.characters.find_by(name: event.options["name"]))
        message = CharacterPoster.show(character)
        Rails.logger.info("Message: #{message}")
        Rails.logger.info("Message length: #{message.length}")
        return event.respond(content: message)
      end
    end
    if character = CharacterPoster.get_character(event.user.id)
      message = CharacterPoster.show(character)
      return event.respond(content: message)
    end

    event.respond(content: "Character not found")
  end

  class << self
    def redis
      @redis ||= Redis.new
    end
  end
end
