class ApplicationController < ActionController::API
  before_action :set_campaign

  private

  def set_campaign
    return unless current_user

    redis = Redis.new
    user_info = redis.get("user_#{current_user.id}")

    if user_info
      @campaign = Campaign.find_by(id: user_info[:campaign_id])
      Rails.logger.info("@campaign: #{@campaign.inspect}")
    end
  end

  def campaign
    @campaign
  end
end
