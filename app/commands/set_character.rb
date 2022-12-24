module SetCharacter
  extend Discordrb::Commands::CommandContainer

  Bot.command(:set) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    args = event.content.split(" ")[1..]
    if args.last =~ /\A\d+\Z/
      name = args[0...-1].join(" ")
      shot = args.last
    else
      event.respond("End your command with a number!")
      return
    end

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if fight.nil?
      event.respond("Can't find that character!")
      return
    end

    character.update(current_shot: shot)
    FightPoster.post_shots(fight)

    event.respond(FightPoster.shots(fight))
  end
end
