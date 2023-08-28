ImageKitIo.configure do |config|
  if Rails.env.development?
    config.public_key = Rails.application.credentials.imagekit&.fetch(:public_key, "")
    config.private_key = Rails.application.credentials.imagekit&.fetch(:private_key, "")
    config.url_endpoint = "https://ik.imagekit.io/nvqgwnjgv/chi-war-#{Rails.env}/"
  end
  config.service = :active_storage
  # config.constants.MISSING_PRIVATE_KEY = 'custom error message'
end
#make sure to replace the your_public_key, your_private_key and your_url_endpoint with actual values
