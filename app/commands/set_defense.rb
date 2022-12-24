module SetDefense
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Set the defense attribute of a character."
    end

    def aliases
      [:def]
    end

    def usage
      <<-TEXT
'/defense Brick Manly 13' to set Brick's Defense to 13.
      TEXT
    end

    def rescue_message
      "There was a problem."
    end

    def attributes
      {
        aliases: aliases,
        description: description,
        usage: usage,
        rescue: rescue_message
      }
    end
  end

  Bot.command(:defense, attributes) do |event|
    key = :defense

    fight = CurrentFight.get
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    args = event.content.split(" ")[1..]
    if args.last =~ /\A\d+\Z/
      name = args[0...-1].join(" ")
      value = args.last
    else
      event.respond("End your command with a number!")
      return
    end

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if fight.nil?
      event.respond("Can't find that character!")
      return
    end

    character.update(key => value)
    FightPoster.post_shots(fight)

    event.respond(FightPoster.shots(fight))
  end
end
