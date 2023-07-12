module SchticksCommands
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:schticks, "List schticks") do |cmd|
    cmd.string(:category, "Category")
    cmd.string(:path, "Path")
    cmd.string(:name, "Name (exact match)")
    cmd.string(:like, "Name (search)")
  end

  Bot.application_command(:schticks) do |event|
    campaign = CurrentCampaign.get(event.server_id)
    if (!campaign)
      event.respond(content: "No campaign set")
    else
      schticks = campaign
        .schticks

      if event.options["category"]
        schticks = schticks.where("schticks.category ILIKE ?", "%#{event.options["category"]}%")
      end

      if event.options["path"]
        schticks = schticks.where("schticks.path ILIKE ?", "%#{event.options["path"]}%")
      end

      if event.options["like"]
        schticks = schticks.where("schticks.name ILIKE ?", "%#{event.options["like"]}%")
      end

      if event.options["name"]
        schticks = schticks.where(name: event.options["name"])
      end

      schticks = schticks.limit(25)

      if schticks.empty?
        event.respond(content: "No schticks")
      else
        if schticks.length <= 10
          messages = schticks.map do |schtick|
            SchtickPoster.show(schtick)
          end
          event.respond(content: messages.join("\n"))
        else
          event.respond(content: schticks.map(&:name).join("\n"))
        end
      end
    end
  end
end
