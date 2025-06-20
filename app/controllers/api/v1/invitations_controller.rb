class Api::V1::InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:redeem, :show]

  def index
    @invitations = current_user.invitations

    render json: @invitations
  end

  def show
    @invitation = Invitation.find(params[:id])
    if @invitation.pending_user.blank?
      @user = User.find_by(email: @invitation.email)
      @invitation.update(pending_user: @user)
    end

    render json: @invitation
  end

  def create
    @invitation = current_user.invitations.new(invitation_params)
    @user = User.find_by(email: @invitation.email)
    @invitation.pending_user = @user
    if @invitation.save
      if @invitation.email
        UserMailer.with(invitation: @invitation).invitation.deliver_later!
      end
      render json: @invitation
    else
      render json: @invitation.errors, status: 400
    end
  end

  def redeem
    @invitation = Invitation.find(params[:id])

    if @invitation.email
      @user = User.find_by(email: @invitation.email) || User.new(user_params.merge(email: @invitation.email))
    elsif @invitation.remaining_count && @invitation.remaining_count <= 0
      render status: 403 and return
    elsif @invitation.remaining_count
      @user = current_user || User.new(user_params)
      @invitation.decrement!(:remaining_count)
    end

    if @user.save && @invitation.campaign.players << @user
      UserMailer.with(invitation: @invitation).invitation.deliver_later!

      if @invitation.email
        @invitation.destroy!
      end
      render json: @user
    else
      render json: @user.errors, status: 400
    end
  end

  def resend
    @invitation = Invitation.find(params[:id])
    if @invitation.email
      UserMailer.with(invitation: @invitation).invitation.deliver_later!
      render status: 200
    else
      render status: 400
    end
  end

  def destroy
    @invitation = current_user.invitations.find(params[:id])
    @invitation.destroy!
    render :ok
  end

  private

  def invitation_params
    params.require(:invitation).permit(:campaign_id, :email, :maximum_count, :remaining_count)
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :password)
  end
end
