module ListFights
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "List all available fights."
    end

    def aliases
      [:list_fights]
    end

    def usage
      <<-TEXT
'/fights'
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

  Bot.command(:fights, attributes) do |event|
    fights = Fight.all

    message = "FIGHTS\n"
    message += "=========\n"
    message += fights.map(&:name).join("\n")
    event.respond(message)
  end
end
