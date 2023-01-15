class ApplicationController < ActionController::API
  before_action :set_campaign

  private

  def set_campaign
    return unless current_user

    redis = Redis.new
    campaign_id = redis.get("user_#{current_user.id}")

    @campaign = Campaign.find_by(id: campaign_id)
    Rails.logger.info("@campaign: #{@campaign.inspect}")
  end

  def campaign
    @campaign
  end
end
