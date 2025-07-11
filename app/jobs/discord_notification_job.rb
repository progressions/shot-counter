class DiscordNotificationJob < ApplicationJob
  queue_as :default

  def perform(fight_id)
    fight = Fight.find(fight_id)
    discord_server_id = fight.server_id || CurrentFight.get_server_id_for_fight(fight_id)
    return unless discord_server_id.present? && fight.channel_id.present?

    raw_content = FightPoster.shots(fight)
    message_content, embed = build_message_params(raw_content)

    begin
      channel = $discord_bot.channel(fight.channel_id)
      message = channel.message(fight.fight_message_id)
      if message.present?
        message.edit(message_content, embed)
      else
        raise Discordrb::Errors::UnknownMessage
      end
    rescue Discordrb::Errors::UnknownMessage
      response = $discord_bot.send_message(fight.channel_id, message_content, false, embed)
      fight.update_column(:fight_message_id, response.id)
    rescue => e
      fight.update_column(:fight_message_id, nil) if fight.fight_message_id.present? && e.is_a?(Discordrb::Errors::UnknownMessage)

      response = $discord_bot.send_message(fight.channel_id, message_content, false, embed)
      fight.update_column(:fight_message_id, response.id)
    end
  end

  private

  def build_message_params(raw_content)
    embed = Discordrb::Webhooks::Embed.new(
      title: "Fight Update",
      color: 3447003, # A nice blue color; adjust as needed
      timestamp: Time.now
    )

    if raw_content.length <= 4096
      embed.description = raw_content
    else
      embed.description = raw_content[0..4095]
      remaining = raw_content[4096..-1]
      part_num = 1

      while remaining.present?
        chunk_size = [1024, remaining.length].min
        chunk = remaining[0..chunk_size - 1]
        embed.add_field(name: "Part #{part_num}", value: chunk, inline: false)
        remaining = remaining[chunk_size..-1]
        part_num += 1

        if embed.fields.length >= 25
          embed.add_field(name: "Truncated", value: "... (content too long for embed limits)", inline: false)
          break
        end
      end
    end

    return "", embed
  end
end
