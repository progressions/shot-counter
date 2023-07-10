module Roll
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:use, "Use character") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:use) do |event|
    character = Character.find_by(name: event.options["name"])
    event.respond(content: "Use character: #{character.name}")
  end
end
