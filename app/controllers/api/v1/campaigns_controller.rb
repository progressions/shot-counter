class Api::V1::CampaignsController < ApplicationController
  before_action :authenticate_user!

  def set
    @campaign = current_user.campaigns.find_by(id: params[:id])

    user_info = {
      "campaign_id" => @campaign&.id
    }
    redis.set("user_#{current_user.id}", user_info.to_json)

    render json: @campaign
  end

  def current
    render json: campaign
  end
end
