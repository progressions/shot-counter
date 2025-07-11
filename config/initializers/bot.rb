require "discordrb"

return if ENV["DISCORD_BOT"] != "true"

$discord_bot = Discordrb::Commands::CommandBot.new(
  token: Rails.application.credentials.dig(:discord, :token),
  client_id: Rails.application.credentials.dig(:discord, :client_id),
  prefix: "/"  # If you use prefix commands; otherwise, can omit
)

Bot = $discord_bot  # Alias for backward compatibility; refactor gradually

# Load all command modules
Dir["#{Rails.root}/lib/commands/*.rb"].each { |file| require file }

# Start the bot in a separate thread (async)
Thread.new do
  Rails.logger.info("DISCORD: Starting Discord bot")
  begin
    $discord_bot.run(true)  # Run asynchronously to not block the thread
    puts "Invite URL: #{$discord_bot.invite_url}"  # Optional: Log invite URL
  rescue => e
    Rails.logger.error("DISCORD: Failed to start bot: #{e.message}, backtrace: #{e.backtrace.join("\n")}")
  end
end
