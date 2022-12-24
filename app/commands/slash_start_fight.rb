module SlashStartFight
  extend Discordrb::Commands::CommandContainer

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
end
