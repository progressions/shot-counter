module SlashCommands
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

  Bot.register_application_command(:list, 'List all available fights.') do |cmd|
  end

  Bot.application_command(:list) do |event|
    fights = Fight.all
    message = "FIGHTS\n"
    message += "=========\n"
    message += fights.map(&:name).join("\n")
    event.respond(content: message)
  end

  Bot.register_application_command(:reset, 'Reset the current fight, moving all characters to shot 0.') do |cmd|
  end

  Bot.application_command(:reset) do |event|
    fight = CurrentFight.get
    if fight.nil?
      event.respond(content: "There is no current fight. /start a fight first!")
      return
    end

    fight.characters.update_all(current_shot: nil)
    CurrentSequence.set(1)
    event.respond(content: FightPoster.shots(fight))
  end

  Bot.register_application_command(:set, "Set a character's current shot") do |cmd|
    cmd.string(:name, "Character name")
    cmd.string(:shot, "Character's current shot")
  end

  Bot.application_command(:set) do |event|
    key = :current_shot

    fight = CurrentFight.get
    if fight.nil?
      event.respond(content: "There is no current fight. /start a fight first!")
      return
    end

    name = event.options["name"]
    value = event.options["shot"]

    character = fight.characters.where("name ILIKE ?", name.downcase).first

    if fight.nil?
      event.respond(content: "Can't find that character!")
      return
    end

    character.update(key => value)

    event.respond(content: FightPoster.shots(fight))
  end

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

  Bot.register_application_command(:show, 'Show current fight') do |cmd|
  end

  Bot.application_command(:show) do |event|
    fight = CurrentFight.get
    if !fight
      event.respond(content: "There is no current fight.")
      return
    end

    event.respond(content: FightPoster.shots(fight))
  end

  Bot.register_application_command(:start, "Start a fight") do |cmd|
    cmd.string(:name, "Fight name")
  end

  Bot.application_command(:start) do |event|
    fight_name = event.options["name"]
    fight = Fight.where("name ILIKE ?", fight_name.downcase).first || Fight.create!(name: fight_name)

    if !fight
      event.respond(content: "Couldn't find that fight!")
      return
    end

    CurrentFight.set(fight)
    event.respond("Starting fight: #{fight.name}")
    event.respond(FightPoster.shots(fight))
  end

  Bot.register_application_command(:halt, "Stop the current fight") do |cmd|
  end

  Bot.application_command(:halt) do |event|
    fight = CurrentFight.get
    if !fight
      event.respond(content: "There is no current fight.")
      return
    end

    CurrentFight.set(nil)
    event.respond(content: "Stopping fight: #{fight.name}")
  end
end
