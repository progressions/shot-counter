class ApplicationController < ActionController::API
  before_action :set_current_campaign

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private

  def record_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end

  def set_current_campaign
    return unless current_user

    @current_campaign = CurrentCampaign.get(user: current_user) || save_current_campaign(current_user.campaigns.first)
  rescue
    @current_user = User.find_by(email: "progressions@gmail.com")
    save_current_campaign(@current_user.campaigns.first)
  end

  def current_campaign
    @current_campaign
  end

  private

  def load_current_campaign
    CurrentCampaign.get(user: current_user)
  end

  def save_current_campaign(campaign)
    return unless campaign

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
end
