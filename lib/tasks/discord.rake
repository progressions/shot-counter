namespace :discord do
  desc "Register Discord slash commands via API"
  task register_commands: :environment do
    require "net/http"
    require "json"

    token = Rails.application.credentials.dig(:discord, :token)
    application_id = Rails.application.credentials.dig(:discord, :client_id)

    # First, check if the command exists and get its ID for patching (to avoid duplicates)
    uri_get = URI("https://discord.com/api/v10/applications/#{application_id}/commands")
    http = Net::HTTP.new(uri_get.host, uri_get.port)
    http.use_ssl = true
    req_get = Net::HTTP::Get.new(uri_get.path, "Authorization" => "Bot #{token}")
    res_get = http.request(req_get)
    commands = JSON.parse(res_get.body)
    start_command = commands.find { |cmd| cmd["name"] == "start" }
    command_id = start_command ? start_command["id"] : nil

    # Prepare the command payload
    body = {
      "name" => "start",
      "description" => "Start a fight",
      "options" => [
        {
          "type" => 3,  # STRING
          "name" => "name",
          "description" => "Fight name",
          "required" => true,
          "autocomplete" => true
        }
      ]
    }.to_json

    if command_id
      # Patch existing command
      uri_patch = URI("https://discord.com/api/v10/applications/#{application_id}/commands/#{command_id}")
      req_patch = Net::HTTP::Patch.new(uri_patch.path, "Authorization" => "Bot #{token}", "Content-Type" => "application/json")
      req_patch.body = body
      res_patch = http.request(req_patch)
      puts "Updated command: #{res_patch.body}"
    else
      # Create new command
      uri_post = URI("https://discord.com/api/v10/applications/#{application_id}/commands")
      req_post = Net::HTTP::Post.new(uri_post.path, "Authorization" => "Bot #{token}", "Content-Type" => "application/json")
      req_post.body = body
      res_post = http.request(req_post)
      puts "Created command: #{res_post.body}"
    end
  rescue => e
    puts "Error registering command: #{e.message}"
  end
end
