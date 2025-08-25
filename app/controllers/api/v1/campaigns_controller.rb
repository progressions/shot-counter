class Api::V1::CampaignsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_gamemaster, only: [:create, :update, :destroy]
  before_action :set_campaign, only: [:show, :set]

  def index
    @campaigns = { gamemaster: current_user.campaigns, player: current_user.player_campaigns }

    render json: @campaigns
  end

  def create
    @campaign = current_user.campaigns.new(campaign_params)

    if @campaign.save
      # Seed the campaign with template content (unless it's a master template)
      unless @campaign.is_master_template?
        CampaignSeederJob.perform_later(@campaign.id)
      end
      
      render json: @campaign
    else
      render json: @campaign.errors, status: 400
    end
  end

  def show
    if @campaign
      render json: @campaign
    else
      render status: nil
    end
  end

  def update
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
    # Only a gamemaster can destroy a campaign
    @campaign = current_user.campaigns.find_by(id: params[:id])
    if @campaign
      if @campaign == current_campaign
        render status: 401 and return
      end

      @campaign.destroy!

      render :ok and return
    else
      render status: 404
    end
  end

  def set
    save_current_campaign(@campaign)
    render json: @campaign
  end

  private

  def require_gamemaster
    if !current_user.gamemaster
      render status: 403 and return
    end
  end

  def set_campaign
    if params[:id] == "current"
      @campaign = current_campaign
    else
      @campaign = (current_user.gamemaster && current_user.campaigns.find_by(id: params[:id])) || current_user.player_campaigns.find_by(id: params[:id])
    end
  end

  def campaign_params
    params.require(:campaign).permit(:name, :description)
  end
end
