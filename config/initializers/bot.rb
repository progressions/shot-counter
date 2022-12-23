require 'discordrb'

ChannelID = 833455969123434496

Bot = Discordrb::Commands::CommandBot.new(
  token: Rails.application.credentials.dig(:discord, :token),
  client_id: Rails.application.credentials.dig(:discord, :client_id),
  prefix: '/'
)

Dir["#{Rails.root}/app/commands/*.rb"].each { |file| require file }

Bot.run(true)
puts "Invite URL: #{Bot.invite_url}"

bot = Discordrb::Bot.new(
  token: Rails.application.credentials.dig(:discord, :token),
  client_id: Rails.application.credentials.dig(:discord, :client_id),
  intents: :all
)
bot.register_application_command(:hello, 'Say hello', server_id: 833455198152032256) do |cmd|
  cmd.string('message', 'Say a message')
end

bot.application_command(:hello) do |event|
  puts event.inspect
  event.respond(content: "Thanks!")
end
