module SetImpairment
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Set the Impairment value of a character."
    end

    def aliases
      [:impairment]
    end

    def usage
      <<-TEXT
'/imp Brick Manly 1' to add 1 Impairment to Brick.
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

  Bot.command(:imp) do |event|
    key = :impairments

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
