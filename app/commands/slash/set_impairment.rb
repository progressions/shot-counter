module Slash
  module SetImpairments
    extend Discordrb::Commands::CommandContainer

    Bot.register_application_command(:impairments, "Set a character's Impairments") do |cmd|
      cmd.string(:name, "Character name")
      cmd.string(:impairments, "Character's Impairments")
    end

    Bot.application_command(:impairments) do |event|
      key = :impairments

      fight = CurrentFight.get
      if fight.nil?
        event.respond(content: "There is no current fight. /start a fight first!")
        return
      end

      name = event.options["name"]
      value = event.options["impairments"]

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
