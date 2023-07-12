module SlashHaltFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:halt, "Stop the current fight") do |cmd|
  end

  Bot.application_command(:halt) do |event|
    fight = CurrentFight.get(event.server_id)
    if !fight
      event.respond(content: "There is no current fight.")
      return
    end

    CurrentFight.set(event.server_id, nil)
    event.respond(content: "Stopping fight: #{fight.name}")
  end
end
