class Api::V1::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_campaign, only: [:show, :set]

  def index
    @campaigns = { gamemaster: current_user.campaigns, player: current_user.player_campaigns }

    render json: @campaigns
  end

  def create
    if !current_user.gamemaster
      render status: 403 and return
    end

    @campaign = current_user.campaigns.new(campaign_params)

    if @campaign.save
      render json: @campaign
    else
      render json: @campaign.errors, status: 400
    end
  end

  def show
    if @campaign
      render json: @campaign
    else
      render status: 404
    end
  end

  def update
    if !current_user.gamemaster
      render status: 403 and return
    end

    @campaign = (current_user.gamemaster && current_user.campaigns.find_by(id: params[:id]))

    if @campaign.nil?
      render status: 404 and return
    end

    if @campaign.update(campaign_params)
      render json: @campaign
    else
      render json: @campaign.errors, status: 400
    end
  end

  def destroy
    if !current_user.gamemaster
      render status: 403 and return
    end

    # Only a gamemaster can destroy a campaign
    @campaign = (current_user.gamemaster && current_user.campaigns.find_by(id: params[:id]))
    if @campaign
      @campaign.destroy!

      render :ok and return
    else
      render status: 404
    end
  end

  def set
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

  private

  def set_campaign
    if params[:id] == "current"
      @campaign = current_campaign
    else
      @campaign = (current_user.gamemaster && current_user.campaigns.find_by(id: params[:id])) || current_user.player_campaigns.find_by(id: params[:id])
    end
  end

  def campaign_params
    params.require(:campaign).permit(:title, :description)
  end
end
