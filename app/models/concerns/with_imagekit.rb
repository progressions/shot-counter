module WithImagekit
  extend ActiveSupport::Concern

  included do
    has_one_attached :image
    after_save :clear_image_url_cache
    after_save :clear_image_positions_on_image_upload
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

  def clear_image_positions_on_image_upload
    # Clear positions when a new image is uploaded
    if image.attached? && image_positions.exists?
      # Check if the attachment was created very recently (during this request)
      # AND this record was just updated (indicating potential image change)
      if image.attachment.created_at > 1.second.ago && updated_at > 1.second.ago
        # Additional safety: only clear if positions were created before the image
        oldest_position = image_positions.minimum(:created_at)
        if oldest_position && oldest_position < image.attachment.created_at
          count_before = image_positions.count
          image_positions.destroy_all
          Rails.logger.info("Cleared #{count_before} image positions for #{self.class.name}##{id} after image upload")
        end
      end
    end
  end
end
