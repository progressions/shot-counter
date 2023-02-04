module SlashAddCharacter
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

    message = []

    if character.nil?
      fight.characters.create!(name: name, current_shot: shot)
      message << "Added #{name} to the current fight."
    else
      message << "Character #{name} is already in the fight!"
    end

    message << FightPoster.shots(fight)

    event.respond(content: message.join("\n"))
  end
end
