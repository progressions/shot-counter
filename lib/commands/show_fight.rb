module ShowFight
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Show the shot counter for the current fight."
    end

    def aliases
      [:fight, :shots, :display]
    end

    def usage
      <<-TEXT
'/show'
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

  Bot.command(:show, attributes) do |event|
    event.respond("Wut")
  end
end
