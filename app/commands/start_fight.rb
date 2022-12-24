module StartFight
  extend Discordrb::Commands::CommandContainer

  Bot.command(:start) do |event|
    args = event.content.split(" ")[1..]
    fight_name = args.join(" ")
    fight = Fight.find_or_create_by(name: fight_name)
    if fight
      CurrentFight.set(fight)
      event.respond("Starting fight: #{fight.name}")
    else
      event.respond("Couldn't find that fight!")
    end
  end
end
