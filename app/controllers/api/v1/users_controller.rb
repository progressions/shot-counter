class Api::V1::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    @users = User.order(email: :asc)
    render json: @users
  end

  def show
    @user = User.find(params[:id])
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

  private

  def user_params
    params.require(:user).permit(:email, :avatar_url, :first_name, :last_name, :admin, :gamemaster)
  end
end
