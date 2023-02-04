module SetCharacter
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Set the current shot of a character. Use this after rolling initiative."
    end

    def aliases
      [:init, :initiative]
    end

    def usage
      <<-TEXT
'/set Brick Manly 18' to set Brick Manly's current shot to 18.
'/init Brick Manly 18' is the same command.
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

  Bot.command(:set, attributes) do |event|
    key = :current_shot

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
