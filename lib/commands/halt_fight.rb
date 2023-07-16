module SlashHaltFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:halt, "Stop the current fight") do |cmd|
  end

  Bot.application_command(:halt) do |event|
    data = CurrentFight.get(server_id: event.server_id)
    if !data[:fight]
      event.respond(content: "There is no current fight.")
      return
    end

    CurrentFight.set(server_id: event.server_id, fight: nil, channel_id: nil)
    event.respond(content: "Stopping fight: #{fight.name}")
  end
end
