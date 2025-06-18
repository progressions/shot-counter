unless ENV['DISCORD_BOT'] == 'false'
  require 'discordrb'

  ChannelID = 833455969123434496

  Bot = Discordrb::Commands::CommandBot.new(
    token: Rails.application.credentials.dig(:discord, :token),
    client_id: Rails.application.credentials.dig(:discord, :client_id),
    prefix: '/'
  )

  Dir["#{Rails.root}/lib/commands/*.rb"].each { |file| require file }

  Bot.run(true)
  puts "Invite URL: #{Bot.invite_url}"
end

# config/initializers/discord_bot.rb
$discord_bot = Discordrb::Bot.new(token: Rails.application.credentials.dig(:discord, :token))

# Start the bot in a separate thread
Thread.new do
  Rails.logger.info("DISCORD: Starting Discord bot")
  begin
    $discord_bot.run
  rescue => e
    Rails.logger.error("DISCORD: Failed to start bot: #{e.message}, backtrace: #{e.backtrace.join("\n")}")
  end
end
