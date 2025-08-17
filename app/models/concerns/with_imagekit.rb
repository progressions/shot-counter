module WithImagekit
  extend ActiveSupport::Concern

  included do
    has_one_attached :image
    after_save :clear_image_url_cache
  end

  def image_url
    return unless image.attached?

    cache_key = "image_url/#{self.class.name}/#{id}/#{image.attachment.id}"
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      metadata_name = image.blob.metadata["name"]
      if metadata_name.blank?
        Rails.logger.warn("ImageKit metadata 'name' missing for #{self.class.name}##{id}, using filename")
        # Use the blob filename as fallback but construct proper ImageKit URL
        "https://ik.imagekit.io/#{Rails.application.credentials.imagekit.id}/chi-war-#{Rails.env}/#{image.blob.filename}"
      else
        "https://ik.imagekit.io/#{Rails.application.credentials.imagekit.id}/chi-war-#{Rails.env}/#{metadata_name}"
      end
    rescue StandardError => e
      Rails.logger.error("ImageKit URL generation failed for #{self.class.name}##{id}: #{e.message}")
      nil
    end
  end

  def image_url=(anything = nil)
    # Unused, kept for compatibility
  end

  private

  def clear_image_url_cache
    if saved_changes.key?("image_attachment_id") && image.attached?
      Rails.cache.delete("image_url/#{self.class.name}/#{id}/#{image.attachment.id}")
    end
  end
end
