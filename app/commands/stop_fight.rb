module StopFight
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Stop the current fight."
    end

    def aliases
      [:stop_fight]
    end

    def usage
      <<-TEXT
'/stop'
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

  Bot.command(:stop, attributes) do |event|
    fight = CurrentFight.get
    if fight
      CurrentFight.set(nil)
      event.respond("Stopping fight: #{fight.name}")
    else
      event.respond("Couldn't find that fight!")
    end
  end
end
