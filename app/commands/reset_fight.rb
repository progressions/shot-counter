module ResetFight
  extend Discordrb::Commands::CommandContainer

  Bot.command(:reset) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    fight.characters.update_all(current_shot: nil)
    event.respond(FightPoster.shots(fight))
  end
end
