class Api::V1::CampaignMembershipsController < ApplicationController
  before_action :authenticate_user!

  def create
    @campaign = current_user.campaigns.find(membership_params[:campaign_id])
    @campaign_membership = @campaign.campaign_memberships.new(membership_params)

    if @campaign_membership.save
      render json: @campaign_membership.campaign
    else
      render json: @campaign_membership.errors, status: 400
    end
  end

  # Fetch by Campaign :id, not the CampaignMembership
  def destroy
    @campaign = current_user.campaigns.find_by(id: params[:campaign_id])

    if @campaign
      # Current user is the Gamemaster, removing a player from their campaign
      @scoped_memberships = @campaign.campaign_memberships
    else
      # Current user is a player, removing their own membership from a campaign
      @scoped_memberships = current_user.campaign_memberships
    end
    @campaign_membership = @scoped_memberships.find_by(campaign_id: params[:campaign_id], user_id: params[:user_id])

    if @campaign_membership
      @campaign_membership.destroy!
      render :ok
    else
      render status: 404
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:campaign_id, :user_id)
  end
end
