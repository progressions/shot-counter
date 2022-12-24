require 'discordrb'

ChannelID = 833455969123434496

Bot = Discordrb::Commands::CommandBot.new(
  token: Rails.application.credentials.dig(:discord, :token),
  client_id: Rails.application.credentials.dig(:discord, :client_id),
  prefix: '/'
)

Dir["#{Rails.root}/app/commands/*.rb"].each { |file| require file }

Bot.register_application_command(:show, 'Show current fight') do |cmd|
end

Bot.application_command(:show) do |event|
  fight = CurrentFight.get
  if fight
    event.respond(content: FightPoster.shots(fight))
  else
    event.respond(content: "There is no current fight.")
  end
end

Bot.run(true)
puts "Invite URL: #{Bot.invite_url}"
