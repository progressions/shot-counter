class Api::V2::InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :register]
  before_action :require_current_campaign, except: [:show, :redeem, :register]
  before_action :require_gamemaster, only: [:index, :create, :destroy, :resend]
  before_action :set_invitation, only: [:show, :destroy, :resend, :redeem, :register]
  before_action :rate_limit_invitations, only: [:create, :resend]
  before_action :rate_limit_registrations, only: [:register]
  
  # GET /api/v2/invitations
  # Returns pending invitations for current campaign
  def index
    @invitations = current_campaign.invitations
                                  .includes(:pending_user, :user)
                                  .order(created_at: :desc)
    
    invitations_data = ActiveModelSerializers::SerializableResource.new(
      @invitations,
      each_serializer: InvitationSerializer,
      adapter: :attributes
    ).serializable_hash
    
    render json: invitations_data
  end
  
  # POST /api/v2/invitations
  # Creates new invitation and sends email
  def create
    @invitation = current_user.invitations.build(invitation_params)
    @invitation.campaign = current_campaign
    @invitation.pending_user = User.find_by(email: @invitation.email)
    
    if @invitation.save
      UserMailer.with(invitation: @invitation).invitation.deliver_later!
      invitation_data = ActiveModelSerializers::SerializableResource.new(
        @invitation,
        serializer: InvitationSerializer,
        adapter: :attributes
      ).serializable_hash
      render json: invitation_data, status: :created
    else
      render json: { errors: @invitation.errors.as_json }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v2/invitations/:id/resend
  # Resends invitation email
  def resend
    UserMailer.with(invitation: @invitation).invitation.deliver_later!
    invitation_data = ActiveModelSerializers::SerializableResource.new(
      @invitation,
      serializer: InvitationSerializer,
      adapter: :attributes
    ).serializable_hash
    render json: invitation_data
  end
  
  # GET /api/v2/invitations/:id
  # Returns invitation details (public endpoint for redemption page)
  def show
    invitation_data = ActiveModelSerializers::SerializableResource.new(
      @invitation,
      serializer: InvitationSerializer,
      adapter: :attributes
    ).serializable_hash
    
    render json: invitation_data
  end
  
  # POST /api/v2/invitations/:id/redeem
  # Redeems invitation and adds user to campaign
  def redeem
    # Check if invitation email matches current user
    if current_user.email != @invitation.email
      return render json: { 
        error: "This invitation is for #{@invitation.email}",
        current_user_email: current_user.email,
        invitation_email: @invitation.email,
        mismatch: true 
      }, status: :forbidden
    end
    
    # Check if user already in campaign
    if @invitation.campaign.users.include?(current_user)
      campaign_data = ActiveModelSerializers::SerializableResource.new(
        @invitation.campaign,
        serializer: CampaignSerializer,
        adapter: :attributes
      ).serializable_hash
      
      return render json: { 
        error: "Already a member of this campaign",
        already_member: true,
        campaign: campaign_data
      }, status: :conflict
    end
    
    # Add user to campaign
    membership = @invitation.campaign.campaign_memberships.build(user: current_user)
    
    if membership.save
      # Clean up invitation
      @invitation.destroy!
      
      # Broadcast update for real-time UI updates
      BroadcastCampaignUpdateJob.perform_later("Campaign", @invitation.campaign.id)
      
      # Return campaign data
      campaign_data = ActiveModelSerializers::SerializableResource.new(
        @invitation.campaign,
        serializer: CampaignSerializer,
        adapter: :attributes
      ).serializable_hash
      
      render json: { 
        campaign: campaign_data,
        message: "Successfully joined #{@invitation.campaign.name}!"
      }, status: :created
    else
      render json: { errors: membership.errors.as_json }, status: :unprocessable_entity
    end
  end
  
  # POST /api/v2/invitations/:id/register
  # Creates new user account for invitation email
  def register
    # Only allow registration for invitations without existing users
    if @invitation.pending_user
      return render json: { 
        error: "User already exists for this email address",
        has_account: true
      }, status: :unprocessable_entity
    end
    
    # Validate email matches invitation
    if params[:email] && params[:email] != @invitation.email
      return render json: { 
        error: "Email must match invitation email",
        invitation_email: @invitation.email
      }, status: :unprocessable_entity
    end

    # Additional security validations
    unless valid_email_format?(@invitation.email)
      return render json: { 
        error: "Invalid email format",
        field: "email"
      }, status: :unprocessable_entity
    end

    unless valid_password?(params[:password])
      return render json: { 
        error: "Password must be at least 8 characters long and contain letters and numbers",
        field: "password"
      }, status: :unprocessable_entity
    end
    
    # Create new user
    user = User.new(
      email: @invitation.email,
      first_name: sanitize_name_field(params[:first_name]),
      last_name: sanitize_name_field(params[:last_name]),
      password: params[:password],
      password_confirmation: params[:password_confirmation],
      pending_invitation_id: @invitation.id
    )
    
    if user.save
      # Devise sends confirmation email automatically
      render json: { 
        message: "Account created! Check #{@invitation.email} for confirmation email.",
        requires_confirmation: true,
        user: {
          id: user.id,
          email: user.email,
          first_name: user.first_name,
          last_name: user.last_name
        }
      }, status: :created
    else
      render json: { errors: user.errors.as_json }, status: :unprocessable_entity
    end
  end
  
  # DELETE /api/v2/invitations/:id
  # Cancels pending invitation
  def destroy
    @invitation.destroy!
    head :no_content
  end
  
  private
  
  def set_invitation
    if action_name.in?(['show', 'redeem', 'register'])
      # For show, redeem, and register actions, find invitation directly (don't scope to current campaign)
      @invitation = Invitation.find(params[:id])
    else
      # For other actions, scope to current campaign
      @invitation = current_campaign.invitations.find(params[:id])
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Invitation not found" }, status: :not_found
  end
  
  def invitation_params
    return {} unless params[:invitation]
    params.require(:invitation).permit(:email)
  end
  
  def require_gamemaster
    unless current_user.gamemaster? || current_campaign.user_id == current_user.id
      render json: { error: "Unauthorized" }, status: :forbidden
    end
  end

  # Rate limiting for invitation creation/resending (5 per minute per user)
  def rate_limit_invitations
    key = "invitation_rate_limit:#{current_user.id}"
    
    begin
      count = Rails.cache.increment(key, 1)
      Rails.cache.write(key, count, expires_in: 1.minute) if count == 1
      
      if count > 5
        render json: { 
          error: "Rate limit exceeded. Please wait before sending more invitations.",
          retry_after: Rails.cache.ttl(key)
        }, status: :too_many_requests
        return false
      end
    rescue => e
      Rails.logger.error "Rate limiting error: #{e.message}"
      # Continue without rate limiting if Redis is unavailable
    end
  end

  # Rate limiting for user registration (3 per minute per IP)
  def rate_limit_registrations
    ip_key = "registration_rate_limit:#{request.remote_ip}"
    email_key = "registration_rate_limit:email:#{@invitation.email}"
    
    begin
      # Rate limit by IP address
      ip_count = Rails.cache.increment(ip_key, 1)
      Rails.cache.write(ip_key, ip_count, expires_in: 1.minute) if ip_count == 1
      
      # Rate limit by email address
      email_count = Rails.cache.increment(email_key, 1)
      Rails.cache.write(email_key, email_count, expires_in: 1.minute) if email_count == 1
      
      if ip_count > 3 || email_count > 3
        render json: { 
          error: "Too many registration attempts. Please wait before trying again.",
          retry_after: [Rails.cache.ttl(ip_key), Rails.cache.ttl(email_key)].max
        }, status: :too_many_requests
        return false
      end
    rescue => e
      Rails.logger.error "Rate limiting error: #{e.message}"
      # Continue without rate limiting if Redis is unavailable
    end
  end

  # Enhanced email validation beyond basic format check
  def valid_email_format?(email)
    return false if email.blank?
    return false if email.length > 254 # RFC 5321 limit
    return false if email.count('@') != 1
    
    local, domain = email.split('@')
    return false if local.blank? || domain.blank?
    return false if local.length > 64 # RFC 5321 limit
    return false if domain.length > 253
    
    # Basic format validation
    email.match?(/\A[^@\s]+@[^@.\s]+(?:\.[^@.\s]+)+\z/)
  end

  # Password strength validation
  def valid_password?(password)
    return false if password.blank?
    return false if password.length < 8
    return false unless password.match?(/[a-zA-Z]/) # Contains letters
    return false unless password.match?(/[0-9]/) # Contains numbers
    true
  end

  # Sanitize name fields to prevent XSS
  def sanitize_name_field(name)
    return nil if name.blank?
    ActionController::Base.helpers.sanitize(name.to_s.strip).truncate(50)
  end
end