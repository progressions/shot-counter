module Slash
  module AddCharacter
    extend Discordrb::Commands::CommandContainer

    Bot.register_application_command(:add, 'Add a character to the current fight') do |cmd|
      cmd.string(:name, "Character name")
      cmd.string(:shot, "Character's current shot")
    end

    Bot.application_command(:add) do |event|
      fight = CurrentFight.get
      if fight.nil?
        event.respond(content: "There is no current fight. /start a fight first!")
        return
      end

      name = event.options[:name] || event.options["name"]
      shot = event.options[:shot] || event.options["shot"] || 3

      character = fight.characters.where("name ILIKE ?", name.downcase).first

      if character.nil?
        fight.characters.create!(name: name, current_shot: shot)
        event.respond(content: "Added #{name} to the current fight.")
      else
        event.respond(content: "Character #{name} is already in the fight!")
      end

      event.respond(content: FightPoster.shots(fight))
    end

  end
end
