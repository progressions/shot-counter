module SlashAct
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:act, 'Have a character take an action') do |cmd|
    cmd.string(:name, "Character name")
    cmd.string(:shots, "Shots to spend")
  end

  Bot.application_command(:act) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond(content: "There is no current fight. /start a fight first!")
      return
    end

    name = event.options[:name] || event.options["name"]
    shots = event.options[:shots] || event.options["shots"] || 3

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if character.nil?
      event.respond(content: "Can't find that character!")
      return
    end

    character.act!(shots)

    event.respond(content: FightPoster.shots(fight))
  end
end
