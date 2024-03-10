module SlashShowFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:show, "Show current fight") do |cmd|
    cmd.boolean(:url, "Show url")
  end

  Bot.application_command(:show) do |event|
    redis = Redis.new

    data = CurrentFight.get(server_id: event.server_id)
    fight = data[:fight]


    if fight
      fight_message_id = redis.get("fight_message_id:#{event.server_id}")
      event.respond(content: "OK", ephemeral: true)

      if fight_message_id.present?
        event.edit_message(fight_message_id, content: FightPoster.shots(fight))
      else
        response = event.send_message(content: FightPoster.shots(fight))

        redis.set("fight_message_id:#{event.server_id}", response.id)
      end
    else
      event.respond(content: "There is no current fight.")
    end
  rescue => e
    Rails.logger.error("DISCORD: #{e.message}")
    redis.set("fight_message_id:#{event.server_id}", nil)
  end
end
