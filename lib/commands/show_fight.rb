module SlashShowFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:show, "Show current fight") do |cmd|
    cmd.boolean(:url, "Show url")
  end

  Bot.application_command(:show) do |event|
    data = CurrentFight.get(server_id: event.server_id)
    fight = data[:fight]
    if !fight
      event.respond(content: "There is no current fight.")
      return
    end

    if event.options["url"]
      event.respond(content: FightPoster.url(fight))
    else
      event.respond(content: FightPoster.shots(fight))
    end
  end
end
