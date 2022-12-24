module Slash
  module ListFights
    extend Discordrb::Commands::CommandContainer

    Bot.register_application_command(:list, 'List all available fights.') do |cmd|
    end

    Bot.application_command(:list) do |event|
      fights = Fight.all
      message = "FIGHTS\n"
      message += "=========\n"
      message += fights.map(&:name).join("\n")
      event.respond(content: message)
    end

  end
end
