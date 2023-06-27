module SetSequence
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Set the current sequence number of the current fight."
    end

    def aliases
      [:seq]
    end

    def usage
      <<-TEXT
'/sequence 2' to set the current sequence to 2.
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

  Bot.command(:sequence, attributes) do |event|
    args = event.content.split(" ")[1..]
    value = args.join(" ")
    if value
      fight = CurrentFight.get
      fight.update(sequence: value)
      event.respond("Current sequence is #{value}")
    else
      event.respond("Couldn't find that fight!")
    end
  end
end
