module Act
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Specify a character to take an action. Actions are 3 shots by default."
    end

    def aliases
      [:int, :interrupt]
    end

    def usage
      <<-TEXT
'/act Brick Manly' to take a normal 3-shot action.
'/act Brick Manly 1' to spend 1 shot.
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

  Bot.command(:act, attributes) do |event|
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
