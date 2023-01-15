class Api::V1::CampaignsController < ApplicationController
  before_action :authenticate_user!

  def create
    @campaign = current_user.campaigns.new(campaign_params)

    if @campaign.save
      render json: @campaign
    else
      render json: @campaign.errors, status: 400
    end
  end

  def set
    @campaign = current_user.campaigns.find_by(id: params[:id])

    user_info = {
      "campaign_id" => @campaign&.id
    }
    redis.set("user_#{current_user.id}", user_info.to_json)

    if params[:id] && @campaign.nil?
      render status: 401
    else
      render json: @campaign
    end
  end

  def current
    render json: campaign
  end

  private

  def campaign_params
    params.require(:campaign).permit(:title, :description)
  end
end
