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
      metadata = image.blob.metadata || {}
      legacy_url = [
        metadata["imagekit_url"],
        metadata[:imagekit_url],
        metadata["url"],
        metadata[:url]
      ].compact_blank.first
      next legacy_url if legacy_url.present?

      path_source =
        metadata["imagekit_file_path"].presence ||
        metadata[:imagekit_file_path].presence ||
        image.blob.key

      path_url = build_imagekit_url_for(path_source)
      next path_url if path_url.present?

      begin
        image.blob.service_url
      rescue NotImplementedError, NoMethodError => e
        Rails.logger.debug("ImageKit service_url unavailable for #{self.class.name}##{id}: #{e.message}") if defined?(Rails)
        blob_url_fallback
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

  def build_imagekit_url_for(path)
    endpoint = Imagekit::Rails.configuration.url_endpoint if defined?(Imagekit::Rails)
    return nil if endpoint.blank? || path.blank?

    "#{endpoint.chomp('/')}/#{path.to_s.delete_prefix('/')}"
  end

  def blob_url_fallback
    configured_options = Rails.configuration.x.try(:active_storage_url_options)
    url_options = (configured_options || {}).symbolize_keys
    url_options[:host] ||= "localhost"
    url_options[:protocol] ||= "http"

    if url_options[:port].blank?
      url_options[:port] =
        if Rails.env.production?
          nil
        else
          3000
        end
    end

    Rails.application.routes.url_helpers.rails_blob_url(image, **url_options.compact)
  rescue StandardError => e
    Rails.logger.warn("Fallback blob URL generation failed for #{self.class.name}##{id}: #{e.message}") if defined?(Rails)
    nil
  end

  def clear_image_url_cache
    if saved_changes.key?("image_attachment_id") && image.attached?
      Rails.cache.delete("image_url/#{self.class.name}/#{id}/#{image.attachment.id}")
    end
  end

  def clear_image_positions_on_image_upload
    # Clear positions when a new image is uploaded
    return unless image.attached? && image_positions.exists?
    
    # Check if the attachment was just created (within the last second)
    # and the record was just updated (indicating an image upload)
    if image.attachment.created_at > 1.second.ago && updated_at > 1.second.ago
      count_before = image_positions.count
      image_positions.destroy_all
      Rails.logger.info("Cleared #{count_before} image positions for #{self.class.name}##{id} after image upload")
    end
  end
end
