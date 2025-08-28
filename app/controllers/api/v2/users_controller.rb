class Api::V2::UsersController < ApplicationController
  include VisibilityFilterable
  
  before_action :authenticate_user!
  before_action :require_admin_or_gamemaster_for_campaign_users, only: [:index]
  before_action :require_admin, only: [:create, :destroy, :show]
  before_action :set_user, only: [:show, :update, :destroy, :remove_image]
  before_action :require_self_or_admin, only: :update
  skip_before_action :authenticate_user!, only: [:register]

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
    query = query.where(apply_visibility_filter)
    query = query.joins(:characters).where(characters: { id: params[:character_id] }) if params[:character_id].present?
    if params[:campaign_id].present?
      # Include both campaign members AND the campaign owner
      campaign = Campaign.find(params[:campaign_id])
      member_user_ids = campaign.users.pluck(:id)
      owner_user_id = campaign.user_id
      all_user_ids = (member_user_ids + [owner_user_id]).uniq.compact
      query = query.where(id: all_user_ids)
    end
    
    # Handle cache buster - users use user-specific cache
    if cache_buster_requested?
      clear_resource_cache("users", current_user.id)
      Rails.logger.info "🔄 Cache buster requested for users"
    end
    
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
      params["visibility"],
      params["show_hidden"],
    ].join("/")
    # Skip cache if cache buster is requested
    cached_result = if cache_buster_requested?
      Rails.logger.info "⚡ Skipping cache for users index"
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
    else
      Rails.cache.fetch(cache_key, expires_in: 5.minutes) do
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

  def register
    # Sanitize input parameters to prevent XSS
    user_data = registration_params.to_h.symbolize_keys
    user_data[:first_name] = sanitize_input(user_data[:first_name]) if user_data[:first_name]
    user_data[:last_name] = sanitize_input(user_data[:last_name]) if user_data[:last_name]
    
    # Set gamemaster to true by default for all new registrations
    user_data[:gamemaster] = true unless user_data.key?(:gamemaster)
    
    # Collect validation errors
    validation_errors = {}
    
    # Manual password confirmation validation since we're using custom password handling
    if user_data[:password] != user_data[:password_confirmation]
      validation_errors[:password_confirmation] = ["doesn't match Password"]
    end
    
    # Manual password presence and length validation
    if user_data[:password].blank?
      validation_errors[:password] = ["can't be blank"]
    elsif user_data[:password].length < 8
      validation_errors[:password] = ["is too short (minimum is 8 characters)"]
    end
    
    # Create user to trigger model validations
    @user = User.new(user_data.except(:password_confirmation))
    
    # Check if user is valid (this will add model validation errors)
    unless @user.valid?
      @user.errors.each do |error|
        validation_errors[error.attribute] ||= []
        validation_errors[error.attribute] << error.message
      end
    end
    
    # Return errors if any validation failed
    if validation_errors.any?
      render json: { errors: validation_errors }, status: :unprocessable_entity
      return
    end
    
    if @user.save
      # Send confirmation email if confirmable is enabled
      @user.send_confirmation_instructions if @user.respond_to?(:send_confirmation_instructions)
      
      # Generate JWT token
      token = encode_jwt(@user)
      response.set_header("Authorization", "Bearer #{token}")
      
      # Return consistent response format matching existing patterns
      render json: {
        code: 201,
        message: "Registration successful. Please check your email to confirm your account.",
        data: UserSerializer.new(@user).serializable_hash,
        payload: JWT.decode(token, Rails.application.credentials.devise_jwt_secret_key!, true, algorithm: 'HS256')[0]
      }, status: :created
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
    service = UserDeletionService.new
    result = service.delete(@user, force: params[:force].present?)
    handle_deletion_result(result)
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

  def require_admin_or_gamemaster_for_campaign_users
    # Allow admin access to all users
    return if current_user.admin?
    
    # Allow gamemaster access only when filtering by their own campaign
    if params[:campaign_id].present?
      begin
        campaign = Campaign.find(params[:campaign_id])
        if campaign.user_id == current_user.id
          return
        else
          render json: { error: "You can only view users from your own campaigns" }, status: :forbidden
          return
        end
      rescue ActiveRecord::RecordNotFound
        render json: { error: "Campaign not found" }, status: :not_found
        return
      end
    end
    
    # Require admin for all other user queries
    render json: { error: "Admin access required" }, status: :forbidden
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

  def registration_params
    params.require(:user).permit(:email, :password, :password_confirmation, :first_name, :last_name, :gamemaster)
  end

  def sanitize_input(input)
    return input unless input.is_a?(String)
    # Remove HTML tags and potential XSS vectors
    ActionController::Base.helpers.strip_tags(input).strip
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
