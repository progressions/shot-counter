module WithImagekit
  extend ActiveSupport::Concern

  def image_url
  return unless image.attached?
  "https://ik.imagekit.io/#{Rails.application.credentials.imagekit.id}/chi-war-#{Rails.env}/#{image.blob.filename}"
end

  def image_url=(anything=nil)
  end
end
