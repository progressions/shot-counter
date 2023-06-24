module SlashSetCharacter
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:set, "Set a character's current shot") do |cmd|
    cmd.string(:name, "Character name")
    cmd.string(:shot, "Character's current shot")
  end

  Bot.application_command(:set) do |event|
    key = :shot

    fight = CurrentFight.get
    if fight.nil?
      event.respond(content: "There is no current fight. /start a fight first!")
      return
    end

    name = event.options["name"]
    value = event.options["shot"]

    fight_character = fight.fight_characters.where("name ILIKE ?", name.downcase).first

    if fight_character.nil?
      event.respond(content: "Can't find that character!")
      return
    end

    fight_character.update(key => value)

    event.respond(content: FightPoster.shots(fight))
  end
end
