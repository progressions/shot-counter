class ApplicationController < ActionController::API
  before_action :set_current_campaign

  private

  def set_current_campaign
    return unless current_user

    json = redis.get("user_#{current_user.id}")

    Rails.logger.info("json: #{json.inspect}")

    if json.present?
      user_info = JSON.parse(json)
      @current_campaign = Campaign.find_by(id: user_info["campaign_id"])
      Rails.logger.info("@campaign: #{@current_campaign.inspect}")
    end
  rescue
  end

  def current_campaign
    @current_campaign
  end

  private

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
end
