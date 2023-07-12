module Roll
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:character, "Use character") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:character) do |event|
    character = Character.find_by(name: event.options["name"])
    CharacterPoster.set_character(event.user.id, character.id)
    event.respond(content: "Using character: #{character.name}")
  end

  Bot.register_application_command(:stats, "List character stats") do |cmd|
  end

  Bot.application_command(:stats) do |event|
    character = CharacterPoster.get_character(event.user.id)
    message = CharacterPoster.show(character)
    event.respond(content: message)
  end

  class << self
    def redis
      @redis ||= Redis.new
    end
  end
end
