class ApplicationController < ActionController::API
  before_action :set_campaign

  private

  def set_campaign
    @campaign = Campaign.find_by(id: params[:campaign_id])
  end

  def campaign
    @campaign
  end
end
