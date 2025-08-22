class Api::V2::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [:index, :create, :destroy, :show]
  before_action :set_user, only: [:show, :update, :destroy, :remove_image]
  before_action :require_self_or_admin, only: :update

  def index
    per_page = (params["per_page"] || 15).to_i
    page = (params["page"] || 1).to_i
    selects = [
      "users.id",
      "users.name",
      "users.first_name",
      "users.last_name",
      "users.email",
      "users.created_at",
      "users.updated_at",
      "users.active",
      "users.admin",
      "users.gamemaster",
    ]
    includes = [
      :image_positions,
      image_attachment: :blob,
      campaigns: { image_attachment: :blob },
    ]
    query = User.select(selects).includes(includes)
    # Apply filters
    query = query.where(id: params["id"]) if params["id"].present?
    if params.key?("ids")
      query = params["ids"].blank? ? query.where(id: nil) : query.where(id: params["ids"].split(","))
    end
    query = query.where("users.first_name ILIKE ? OR users.last_name ILIKE ?", "%#{params['search']}%", "%#{params['search']}%") if params["search"].present?
    query = query.where("users.email ILIKE ?", "%#{params['email']}%") if params["email"].present?
    if params["show_all"] == "true"
      query = query.where(active: [true, false, nil])
    else
      query = query.where(active: true)
    end
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    query = query.joins(:campaign_memberships).where(campaign_memberships: { campaign_id: params[:campaign_id] }) if params[:campaign_id].present?
    # Cache key
    cache_key = [
      "users/index",
      current_user.id,
      sort_order,
      page,
      per_page,
      params["id"],
      params["email"],
      params["search"],
      params["campaign_id"],
      params["character_id"],
      params["show_all"],
    ].join("/")
    cached_result = Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
      users = query.order(Arel.sql(sort_order))
      users = paginate(users, per_page: per_page, page: page)
      {
        "users" => ActiveModelSerializers::SerializableResource.new(
          users,
          each_serializer: params[:autocomplete] ? UserAutocompleteSerializer : UserIndexSerializer,
          adapter: :attributes
        ).serializable_hash,
        "meta" => pagination_meta(users)
      }
    end
    render json: cached_result
  end

  def show
    render json: @user, serializer: UserSerializer, status: :ok
  end

  def current
    render json: current_user, serializer: UserSerializer, status: :ok
  end

  def profile
    render json: current_user, serializer: UserSerializer, status: :ok
  end

  def update_profile
    if params[:user].present? && params[:user].is_a?(String)
      begin
        user_data = JSON.parse(params[:user]).symbolize_keys
      rescue JSON::ParserError
        render json: { error: "Invalid user data format" }, status: :bad_request
        return
      end
    else
      user_data = profile_params.to_h.symbolize_keys
    end
    
    if params[:image].present?
      current_user.image.purge if current_user.image.attached?
      current_user.image.attach(params[:image])
    end
    
    if current_user.update(user_data)
      token = encode_jwt(current_user)
      response.set_header("Authorization", "Bearer #{token}")
      render json: current_user, serializer: UserSerializer
    else
      render json: { errors: current_user.errors }, status: :unprocessable_entity
    end
  end

  def create
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
    @user = User.new(user_data)
    if params[:image].present?
      @user.image.attach(params[:image])
    end
    if @user.save
      token = encode_jwt(@user)
      response.set_header("Authorization", "Bearer #{token}")
      render json: @user, serializer: UserSerializer, status: :created
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def update
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
    if params[:image].present?
      @user.image.purge if @user.image.attached?
      @user.image.attach(params[:image])
    end
    if @user.update(user_data)
      token = encode_jwt(@user)
      response.set_header("Authorization", "Bearer #{token}")
      render json: @user, serializer: UserSerializer
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.characters.any? && !params[:force]
      render json: { errors: { characters: true } }, status: 400 and return
    end
    if params[:force]
      @user.characters.update_all(user_id: nil)
      @user.campaigns.update_all(user_id: nil)
    end
    if @user.destroy!
      render :ok
    else
      render json: { errors: @user.errors }, status: 400
    end
  end

  def remove_image
    if @user != current_user && !current_user.admin?
      render json: { error: "Admin access required to remove another user's image" }, status: :forbidden
      return
    end
    @user.image.purge if @user.image.attached?
    if @user.save
      token = encode_jwt(@user)
      response.set_header("Authorization", "Bearer #{token}")
      render json: @user, serializer: UserSerializer
    else
      render json: { errors: @user.errors }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    if params[:id] == "confirmation_token"
      @user = User.find_by(confirmation_token: params[:confirmation_token])
    else
      @user = User.find(params[:id])
    end
    unless @user
      render json: { error: "Record not found" }, status: :not_found
      return
    end
  end

  def require_admin
    unless current_user.admin?
      render json: { error: "Admin access required" }, status: :forbidden
      return
    end
  end

  def require_self_or_admin
    unless @user == current_user || current_user.admin?
      render json: { error: "You can only edit your own attributes or must be an admin" }, status: :forbidden
      return
    end
  end

  def encode_jwt(user)
    payload = {
      jti: SecureRandom.uuid,
      user: UserSerializer.new(user).serializable_hash,
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

  def profile_params
    params.require(:user).permit(:email, :first_name, :last_name, :image)
  end

  def sort_order
    sort = params["sort"] || "created_at"
    order = params["order"] || "DESC"
    if sort == "name"
      "LOWER(users.last_name) #{order}, LOWER(users.first_name) #{order}"
    elsif sort == "first_name"
      "LOWER(users.first_name) #{order}, LOWER(users.last_name) #{order}"
    elsif sort == "last_name"
      "LOWER(users.last_name) #{order}, LOWER(users.first_name) #{order}"
    elsif sort == "email"
      "LOWER(users.email) #{order}"
    elsif sort == "created_at"
      "users.created_at #{order}"
    elsif sort == "updated_at"
      "users.updated_at #{order}"
    else
      "users.created_at DESC"
    end
  end
end
