module CacheVersionable
  extend ActiveSupport::Concern

  included do
    after_commit :increment_cache_version, on: [:create, :update, :destroy]
  end

  private

  def increment_cache_version
    # Use Rails.cache.increment to atomically increment the version
    # This creates a single cache key per entity type per campaign
    cache_key = "#{self.class.table_name}_version_#{campaign_id}"
    
    # Delete the key to force all cached queries to miss
    # This is simpler than incrementing and doesn't require tracking version numbers
    Rails.cache.delete(cache_key)
    
    # Generate a new random version
    Rails.cache.write(cache_key, SecureRandom.hex(8), expires_in: 1.day)
    
    Rails.logger.info "🔄 Cache invalidated for #{self.class.name} in campaign #{campaign_id}"
  end

  module ClassMethods
    def cache_version_for(campaign_id)
      cache_key = "#{table_name}_version_#{campaign_id}"
      # Return existing version or generate a new one
      Rails.cache.fetch(cache_key, expires_in: 1.day) { SecureRandom.hex(8) }
    end
  end
end