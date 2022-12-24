module ListFights
  extend Discordrb::Commands::CommandContainer

  Bot.command(:fights) do |event|
    fights = Fight.all
    message = "FIGHTS\n"
    message += "=========\n"
    message += fights.map(&:name).join("\n")
    event.respond(message)
  end
end
