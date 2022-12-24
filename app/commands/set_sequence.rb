module SetSequence
  extend Discordrb::Commands::CommandContainer

  Bot.command(:seq) do |event|
    set_sequence(event)
  end

  Bot.command(:sequence) do |event|
    set_sequence(event)
  end

  class << self
    def set_sequence(event)
      args = event.content.split(" ")[1..]
      value = args.join(" ")
      if value
        CurrentSequence.set(value)
        event.respond("Current sequence is #{value}")
      else
        event.respond("Couldn't find that fight!")
      end
    end
  end
end
