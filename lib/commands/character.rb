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
    else
      if event.options["name"]
        if (character = campaign.characters.find_by(name: event.options["name"]))
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

  class << self
    def redis
      @redis ||= Redis.new
    end
  end
end
