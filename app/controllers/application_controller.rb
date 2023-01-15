class ApplicationController < ActionController::API
  before_action :set_campaign

  private

  def set_campaign
    return unless current_user

    redis = Redis.new
    json = redis.get("user_#{current_user.id}")

    Rails.logger.info("json: #{json.inspect}")

    if json.present?
      user_info = JSON.parse(json)
      @campaign = Campaign.find_by(id: user_info[:campaign_id])
      Rails.logger.info("@campaign: #{@campaign.inspect}")
    end
  rescue
  end

  def campaign
    @campaign
  end
end
