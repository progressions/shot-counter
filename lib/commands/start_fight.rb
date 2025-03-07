module SlashStartFight
  extend Discordrb::Commands::CommandContainer

  Bot.register_application_command(:start, "Start a fight") do |cmd|
    cmd.string(:name, "Fight name")
  end

  Bot.application_command(:start) do |event|
    redis = Redis.new
    campaign = CurrentCampaign.get(server_id: event.server_id)

    fight_name = event.options["name"]
    fight = campaign
      .fights
      .active
      .where("name ILIKE ?", fight_name.downcase).first

    if !fight
      event.respond(content: "Couldn't find that fight!")
      return
    end

    redis.set("fight_message_id:#{event.server_id}", nil)
    CurrentFight.set(server_id: event.server_id, fight: fight, channel_id: event.channel_id)
    event.respond(content: "Starting fight: #{fight.name}")
    # response = Bot.send_message(event.channel_id, FightPoster.shots(fight))
    # redis.set("fight_message_id:#{event.server_id}", response.id)
  end
end
