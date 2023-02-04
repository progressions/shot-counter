module StartFight
  extend Discordrb::Commands::CommandContainer

  class << self
    def description
      "Start a fight, either finding it by name, or creating a new fight with a specified name."
    end

    def aliases
      [:new_fight]
    end

    def usage
      <<-TEXT
'/start Warehouse fight' to locate the fight by name and start it, or create it if it doesn't exist.
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

  Bot.command(:start, attributes) do |event|
    args = event.content.split(" ")[1..]
    fight_name = args.join(" ")
    fight = Fight.where("name ILIKE ?", fight_name.downcase).first || Fight.create!(name: fight_name)

    if fight
      CurrentFight.set(fight)
      event.respond("Starting fight: #{fight.name}")
      FightPoster.post_shots(fight)
      event.respond(FightPoster.shots(fight))
    else
      event.respond("Couldn't find that fight!")
    end
  end
end
