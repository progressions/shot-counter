Notion.configure do |config|
  config.token = Rails.application.credentials.dig(:notion, :token)
end
