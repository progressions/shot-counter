# app/controllers/api/v1/users_controller.rb
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
      token = encode_jwt(@user)
      response.set_header("Authorization", "Bearer #{token}")
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
      token = encode_jwt(@user)
      response.set_header("Authorization", "Bearer #{token}")
      render json: @user
    else
      render json: @user.errors, status: 400
    end
  end

  private

  def encode_jwt(user)
    payload = {
      jti: SecureRandom.uuid,
      user: user.as_json(only: [:email, :admin, :first_name, :last_name, :gamemaster, :current_campaign, :created_at, :updated_at, :image_url]),
      sub: user.id,
      scp: "user",
      aud: nil,
      iat: Time.now.to_i,
      exp: 7.days.from_now.to_i,
    }
    JWT.encode(payload, Rails.application.credentials.devise_jwt_secret_key!, "HS256")
  end

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :admin, :gamemaster, :image)
  end
end
