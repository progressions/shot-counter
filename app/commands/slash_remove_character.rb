module SlashRemoveCharacter
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:rem, "Remove a character from the current fight") do |cmd|
    cmd.string(:name, "Character name")
  end

  Bot.application_command(:rem) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond(content: "There is no current fight. /start a fight first!")
      return
    end

    name = event.options[:name] || event.options["name"]
    shot = event.options[:shot] || event.options["shot"] || 3

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    message = []

    if character.nil?
      event.respond(content: "Could not find the character #{name}!")
      return
    end

    character.destroy!
    message << "Removed #{name} from the current fight."

    message << FightPoster.shots(fight)

    event.respond(content: message.join("\n"))
  end
end
