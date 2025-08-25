class ApplicationController < ActionController::API
  before_action :set_current_campaign

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  serialization_scope :current_user # Optional, if you need to pass current_user to serializers
  def default_serializer_options
    { serializer: ActiveModel::Serializer.serializer_for }
  end

  private

  def record_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end

  def set_current_campaign
    return unless current_user

    @current_campaign ||= CurrentCampaign.get(user: current_user)
  end

  def current_campaign
    @current_campaign
  end

  private

  def load_current_campaign
    CurrentCampaign.get(user: current_user)
  end

  def save_current_campaign(campaign)
    CurrentCampaign.set(user: current_user, campaign: campaign)
  end

  def require_current_campaign
    if !current_campaign
      render status: 500
    end
  end

  def redis
    @redis ||= Redis.new
  end

  def pagination_meta(object)
    {
      current_page: object.current_page,
      next_page: object.next_page,
      prev_page: object.prev_page,
      total_pages: object.total_pages,
      total_count: object.total_count
    }
  end

  # Cache buster helpers
  def cache_buster_requested?
    return false unless params[:cache_buster].present?
    
    # Treat these values as truthy
    truthy_values = %w[true 1 yes TRUE True YES Yes]
    truthy_values.include?(params[:cache_buster].to_s.strip)
  end

  def clear_resource_cache(resource_name, identifier = nil)
    # Clear cache for a specific resource type
    # identifier can be campaign_id or user_id depending on the resource
    identifier ||= current_campaign&.id
    return unless identifier

    cache_pattern = "#{resource_name}/index/#{identifier}/*"
    
    begin
      Rails.cache.delete_matched(cache_pattern)
      Rails.logger.info "🗑️ Cache cleared for pattern: #{cache_pattern}"
    rescue => e
      Rails.logger.warn "Cache delete_matched not supported or failed: #{e.message}"
    end
  end
end
