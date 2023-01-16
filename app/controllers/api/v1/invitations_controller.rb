class Api::V1::InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:redeem]

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

  def redeem
    @invitation = Invitation.find(params[:id])
    if @invitation.email && current_user.email == @invitation.email
      @user = current_user
    else
      @user = User.new(user_params)
    end
    if @invitation.campaign.players << @user
      @invitation.destroy!
      render json: @user
    else
      render json: @user.errors, status: 400
    end
  end

  def destroy
    @invitation = current_user.invitations.find(params[:id])
    @invitation.destroy!
    render :ok
  end

  private

  def invitation_params
    params.require(:invitation).permit(:campaign_id, :email)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name)
  end
end
