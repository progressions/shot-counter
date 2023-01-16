class Api::V1::InvitationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @invitations = current_user.invitations

    render json: @invitations
  end

  def create
    @invitation = current_user.invitations.new(invitation_params)
    if @invitation.save
      render json: @invitation
    else
      render json: @invitation.errors, status: 400
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:campaign_id)
  end
end
