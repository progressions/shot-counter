class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = current_campaign.players.order(email: :asc)
    render json: @users
  end

  def show
    if params[:id] == "confirmation_token"
      @user = User.find_by(confirmation_token: params[:confirmation_token])
    else
      @user = User.find(params[:id])
    end
    render json: @user
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors.full_messages, status: 400
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    render :ok
  end

  def remove_image
    @user = current_user
    @user.image.purge

    if @user.save
      render json: @user
    else
      render @user.errors, status: 400
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :admin, :gamemaster, :image)
  end
end
