module Slash
  module SetDefense
    extend Discordrb::Commands::CommandContainer

    Bot.register_application_command(:defense, "Set a character's Defense AV") do |cmd|
      cmd.string(:name, "Character name")
      cmd.string(:defense, "Character's Defense")
    end

    Bot.application_command(:defense) do |event|
      key = :defense

      fight = CurrentFight.get
      if fight.nil?
        event.respond(content: "There is no current fight. /start a fight first!")
        return
      end

      name = event.options["name"]
      value = event.options["defense"]

      character = fight.characters.where("name ILIKE ?", name.downcase).first

      if fight.nil?
        event.respond(content: "Can't find that character!")
        return
      end

      character.update(key => value)

      event.respond(content: FightPoster.shots(fight))
    end

  end
end
