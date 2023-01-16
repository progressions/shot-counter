class Api::V1::CampaignMembershipsController < ApplicationController
  before_action :authenticate_user!

  def index
    @campaigns = current_user.player_campaigns

    render json: @campaigns
  end

  def create
    @campaign_membership = current_user.campaign_memberships.new(membership_params)

    if @campaign_membership.save
      render json: @campaign_membership.campaign
    else
      render json: @campaign_membership.errors, status: 400
    end
  end

  # Fetch by Campaign :id, not the CampaignMembership
  def destroy
    @campaign_membership = current_user.campaign_memberships.find_by(campaign_id: params[:id])
    if @campaign_membership
      @campaign_membership.destroy!
      render :ok
    else
      render status: 404
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:campaign_id)
  end
end
