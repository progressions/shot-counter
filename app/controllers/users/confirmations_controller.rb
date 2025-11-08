# frozen_string_literal: true

class Users::ConfirmationsController < Devise::ConfirmationsController
  respond_to :json
  before_action :rate_limit_confirmations, only: [:show, :create]

  # GET /resource/confirmation/new
  # def new
  #   super
  # end

  # POST /resource/confirmation
  def create
    @user = User.find_by(confirmation_token: params[:confirmation_token])

    if !@user
      render status: 404 and return
    end

    if @user.confirm
      # Handle pending invitation auto-join after confirmation
      if @user.pending_invitation_id
        handle_pending_invitation_join(@user)
      end
      
      render json: @user
    else
      render json: @user.errors, status: 400
    end
  end

  # GET /resource/confirmation?confirmation_token=abcdef
  def show
    @user = User.find_by(confirmation_token: params[:confirmation_token])
    
    if !@user
      render json: { error: "Invalid confirmation token" }, status: :not_found
      return
    end
    
    if @user.confirmed?
      render json: { 
        message: "Account already confirmed",
        user: UserSerializer.new(@user).serializable_hash
      }, status: :ok
      return
    end
    
    if @user.confirm
      # Handle pending invitation auto-join after confirmation
      if @user.pending_invitation_id
        handle_pending_invitation_join(@user)
      end
      
      # Just confirm success, user will need to login manually
      render json: {
        message: "Account confirmed successfully! Please log in to continue.",
        redirect: "/login"
      }, status: :ok
    else
      render json: { 
        error: "Failed to confirm account",
        errors: @user.errors.full_messages 
      }, status: :unprocessable_content
    end
  end

  private

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

  def handle_pending_invitation_join(user)
    invitation = Invitation.find_by(id: user.pending_invitation_id)
    
    return unless invitation
    
    # Add user to campaign if not already a member
    unless invitation.campaign.users.include?(user)
      membership = invitation.campaign.campaign_memberships.build(user: user)
      
      if membership.save
        # Set as current campaign if user doesn't have one
        if user.current_campaign_id.nil?
          user.update(current_campaign_id: invitation.campaign_id)
        end
        
        # Clean up invitation and pending association
        user.update(pending_invitation_id: nil)
        invitation.destroy!
        
        # Broadcast update for real-time UI updates
        BroadcastCampaignUpdateJob.perform_later("Campaign", invitation.campaign.id)
        
        Rails.logger.info "User #{user.email} auto-joined campaign #{invitation.campaign.name} after confirmation"
      else
        Rails.logger.error "Failed to auto-join user #{user.email} to campaign: #{membership.errors.full_messages}"
      end
    else
      # User already in campaign, just clean up
      user.update(pending_invitation_id: nil)
      invitation.destroy!
    end
  rescue => e
    Rails.logger.error "Error handling pending invitation for user #{user.email}: #{e.message}"
  end

  # Rate limiting for confirmation attempts (5 per minute per IP)
  def rate_limit_confirmations
    ip_key = "confirmation_rate_limit:#{request.remote_ip}"
    
    begin
      count = Rails.cache.increment(ip_key, 1)
      Rails.cache.write(ip_key, count, expires_in: 1.minute) if count == 1
      
      if count > 5
        render json: { 
          error: "Too many confirmation attempts. Please wait before trying again.",
          retry_after: Rails.cache.ttl(ip_key)
        }, status: :too_many_requests
        return false
      end
    rescue => e
      Rails.logger.error "Rate limiting error: #{e.message}"
      # Continue without rate limiting if Redis is unavailable
    end
  end

  # protected

  def respond_with(resource, options={})
    if resource.persisted?
      render json: {
        status: { code: 200, message: 'Signed up successfully', data: resource }
      }
    else
      render json: {
        status: { message: 'User could not be created successfully', errors: resource.errors.full_messages }
      }, status: :unprocessable_content
    end
  end

  # The path used after resending confirmation instructions.
  # def after_resending_confirmation_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  # The path used after confirmation.
  # def after_confirmation_path_for(resource_name, resource)
  #   super(resource_name, resource)
  # end
end
