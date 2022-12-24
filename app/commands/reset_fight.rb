module ResetFight
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Reset the current fight, moving all characters to shot 0."
    end

    def aliases
      []
    end

    def usage
      <<-TEXT
'/reset'
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

  Bot.command(:reset, attributes) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond("There is no current fight. /start a fight first!")
      return
    end

    fight.characters.update_all(current_shot: nil)
    CurrentSequence.set(1)
    event.respond(FightPoster.shots(fight))
  end
end
