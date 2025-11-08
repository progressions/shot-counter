credentials = Rails.application.credentials.imagekit || {}

Imagekit::Rails.configure do |config|
  config.public_key = credentials[:public_key].presence || ENV["IMAGEKIT_PUBLIC_KEY"]
  config.private_key = credentials[:private_key].presence || ENV["IMAGEKIT_PRIVATE_KEY"]

  explicit_endpoint =
    credentials[:url_endpoint].presence ||
    ENV["IMAGEKIT_URL_ENDPOINT"].presence

  config.url_endpoint =
    explicit_endpoint ||
    begin
      imagekit_id = credentials[:id].presence || ENV["IMAGEKIT_ID"]
      imagekit_id.present? ? "https://ik.imagekit.io/#{imagekit_id}/chi-war-#{Rails.env}/" : nil
    end

  unless config.url_endpoint.present?
    Rails.logger.warn("[ImageKit] url_endpoint is not configured; uploads will fail") if defined?(Rails)
  end
end
