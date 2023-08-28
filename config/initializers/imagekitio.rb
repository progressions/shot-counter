ImageKitIo.configure do |config|
  config.public_key = Rails.application.credentials.imagekit&.fetch(:public_key, "")
  config.private_key = Rails.application.credentials.imagekit&.fetch(:private_key, "")
  config.url_endpoint = "https://ik.imagekit.io/nvqgwnjgv/chi-war-#{Rails.env}/"
  config.service = :active_storage
  # config.constants.MISSING_PRIVATE_KEY = 'custom error message'
end
