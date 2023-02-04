module CommandList
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Show a detailed list of commands."
    end

    def aliases
      [:cmds]
    end

    def usage
      <<-TEXT
'/commands'
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

  Bot.command(:commands, attributes) do |event|
    message = <<-TEXT
      /start <Fight name>           - Start a fight
      /stop                         - Stop the current fight
      /reset                        - Reset everyone's current shot to start a new sequence
      /add <Character> <num>        - Add a character to the fight on shot [num]
      /act <Character> [shots]      - The character acts, specify a number of shots (default is 3)
      /show                         - Show the current shot counter
    TEXT
    event.respond(message)
  end
end
