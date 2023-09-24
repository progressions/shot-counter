module SlashHaltFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:halt, "Stop the current fight") do |cmd|
  end

  Bot.application_command(:halt) do |event|
    data = CurrentFight.get(server_id: event.server_id)
    fight = data[:fight]
    if fight.nil?
      event.respond(content: "There is no current fight.")
    else
      event.respond(content: "Stopping fight: #{fight.name}")
    end

    CurrentFight.set(server_id: event.server_id, fight: nil, channel_id: nil)
  end
end
