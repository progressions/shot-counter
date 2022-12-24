module ShowFight
  extend Discordrb::Commands::CommandContainer

  Bot.command(:show) do |event|
    fight = CurrentFight.get
    if fight
      FightPoster.post_shots(fight)
      event.respond(FightPoster.shots(fight))
    else
      event.respond("There is no current fight.")
    end
  end
end
