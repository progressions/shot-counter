module StopFight
  extend Discordrb::Commands::CommandContainer

  Bot.command(:stop) do |event|
    fight = CurrentFight.get
    if fight
      CurrentFight.set(nil)
      event.respond("Stopping fight: #{fight.name}")
    else
      event.respond("Couldn't find that fight!")
    end
  end
end
