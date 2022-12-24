module SlashHaltFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:halt, "Stop the current fight") do |cmd|
  end

  Bot.application_command(:halt) do |event|
    fight = CurrentFight.get
    if !fight
      event.respond(content: "There is no current fight.")
      return
    end

    CurrentFight.set(nil)
    event.respond(content: "Stopping fight: #{fight.name}")
  end
end
