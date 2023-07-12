module SlashStartFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:start, "Start a fight") do |cmd|
    cmd.string(:name, "Fight name")
  end

  Bot.application_command(:start) do |event|
    campaign = CurrentCampaign.get(event.server.id)

    fight_name = event.options["name"]
    fight = campaign
      .fights
      .active
      .where("name ILIKE ?", fight_name.downcase).first

    if !fight
      event.respond(content: "Couldn't find that fight!")
      return
    end

    CurrentFight.set(event.server.id, fight)
    event.respond(content: "Starting fight: #{fight.name}")
    event.respond(content: FightPoster.shots(fight))
  end
end
