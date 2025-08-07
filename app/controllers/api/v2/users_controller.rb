class Api::V2::UsersController < ApplicationController
  before_action :authenticate_user!

  def index
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"

    if sort == "name"
      sort = Arel.sql("LOWER(users.last_name) #{order}, LOWER(users.first_name) #{order}")
    elsif sort == "email"
      sort = Arel.sql("LOWER(users.email) #{order}")
    elsif sort == "created_at"
      sort = Arel.sql("users.created_at #{order}")
    else
      sort = Arel.sql("users.created_at DESC")
    end

    @users = User
      .with_attached_image
      .order(sort)
    @users = paginate(@users, per_page: (params[:per_page] || 12), page: (params[:page] || 1))

    render json: {
      users: ActiveModel::Serializer::CollectionSerializer.new(@users, each_serializer: UserSerializer),
      meta: pagination_meta(@users),
    }
  end

  def show
    if params[:id] == "confirmation_token"
      @user = User.find_by(confirmation_token: params[:confirmation_token])
    else
      @user = User.find(params[:id])
    end
    render json: @user, serializer: UserSerializer, status: :ok
  end

  def current
    render json: current_user, serializer: UserSerializer, status: :ok
  end

  def create
    # Check if request is multipart/form-data with a JSON string
    if params[:user].present? && params[:user].is_a?(String)
      begin
        user_data = JSON.parse(params[:user]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid user data format" }, status: :bad_request
        return
      end
    else
      user_data = user_params.to_h.symbolize_keys
    end

    user_data.slice(:name, :description, :active, :faction_id)

    @user = User.new(user_data)

    # Handle image attachment if present
    if params[:image].present?
      @user.image.attach(params[:image])
    end

    if @user.save
      render json: @user, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @user = User.find(params[:id])

    # Handle multipart/form-data for updates if present
    if params[:user].present? && params[:user].is_a?(String)
      begin
        user_data = JSON.parse(params[:user]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid user data format" }, status: :bad_request
        return
      end
    else
      user_data = user_params.to_h.symbolize_keys
    end
    user_data = user_data.slice(:name, :description, :active, :faction_id, :character_ids)

    # Handle image attachment if present
    if params[:image].present?
      @user.image.purge if @user.image.attached? # Remove existing image
      @user.image.attach(params[:image])
    end

    if @user.update(user_data)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
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
      user: user.as_v1_json(only: [:email, :admin, :first_name, :last_name, :gamemaster, :current_campaign, :created_at, :updated_at, :image_url]),
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
