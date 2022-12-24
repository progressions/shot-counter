module Act
  extend Discordrb::Commands::CommandContainer

  Bot.command(:act) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    args = event.content.split(" ")[1..]
    shots = 3
    if args.last =~ /\A\d+\Z/
      name = args[0...-1].join(" ")
      shots = args.last
    else
      name = args[0..].join(" ")
    end

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if character.nil?
      event.respond("Can't find that character!")
      return
    end

    character.act!(shots)
    FightPoster.post_shots(fight)

    event.respond(FightPoster.shots(fight))
  end
end
