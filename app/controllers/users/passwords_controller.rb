# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  respond_to :json
  before_action :rate_limit_password_resets, only: [:create]
  before_action :validate_reset_token, only: [:update]

  # POST /resource/password
  def create
    # Enhanced email validation
    email = password_reset_params[:email]
    unless valid_email_format?(email)
      return render json: {
        error: "Invalid email format",
        field: "email"
      }, status: :unprocessable_entity
    end

    # Find user by email (case insensitive)
    user = User.find_by('LOWER(email) = LOWER(?)', email)
    
    if user
      # Always send success response for security (prevent email enumeration)
      user.send_reset_password_instructions
      
      # Log the attempt for security monitoring
      Rails.logger.info "Password reset requested for user: #{email.downcase} from IP: #{request.remote_ip}"
    else
      # Log failed attempt
      Rails.logger.warn "Password reset attempted for non-existent email: #{email.downcase} from IP: #{request.remote_ip}"
    end
    
    # Always return success to prevent email enumeration attacks
    render json: {
      message: "If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes."
    }, status: :ok
  end

  # PUT /resource/password
  def update
    token = password_reset_params[:reset_password_token]
    password = password_reset_params[:password]
    password_confirmation = password_reset_params[:password_confirmation]
    
    # Validate password strength
    unless valid_password?(password)
      return render json: {
        error: "Password must be at least 8 characters long and contain letters and numbers",
        field: "password"
      }, status: :unprocessable_entity
    end
    
    # Validate password confirmation
    unless password == password_confirmation
      return render json: {
        error: "Password confirmation doesn't match password",
        field: "password_confirmation"
      }, status: :unprocessable_entity
    end

    # Find user by token
    user = User.with_reset_password_token(token)
    
    unless user
      return render json: {
        error: "Password reset token is invalid or has expired"
      }, status: :unprocessable_entity
    end
    
    # Reset password
    if user.reset_password(password, password_confirmation)
      Rails.logger.info "Password reset completed for user: #{user.email} from IP: #{request.remote_ip}"
      
      render json: {
        message: "Your password has been changed successfully.",
        redirect: "/login"
      }, status: :ok
    else
      render json: {
        error: "Failed to reset password",
        errors: user.errors.full_messages
      }, status: :unprocessable_entity
    end
  end

  private

  def password_reset_params
    params.require(:user).permit(:email, :password, :password_confirmation, :reset_password_token)
  rescue ActionController::ParameterMissing
    # Handle missing user parameter
    params.permit(:email, :password, :password_confirmation, :reset_password_token)
  end

  # Rate limiting for password reset requests
  def rate_limit_password_resets
    email = params.dig(:user, :email) || params[:email]
    return unless email
    
    email_key = "password_reset_rate_limit:email:#{email.downcase}"
    ip_key = "password_reset_rate_limit:ip:#{request.remote_ip}"
    
    begin
      # Rate limit by email (3 per hour)
      email_count = Rails.cache.read(email_key) || 0
      email_count += 1
      Rails.cache.write(email_key, email_count, expires_in: 1.hour)
      
      # Rate limit by IP (5 per hour)
      ip_count = Rails.cache.read(ip_key) || 0
      ip_count += 1
      Rails.cache.write(ip_key, ip_count, expires_in: 1.hour)
      
      if email_count > 3 || ip_count > 5
        render json: {
          error: "Too many password reset attempts. Please wait before trying again.",
          retry_after: 3600
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

  # Validate reset token exists and hasn't expired
  def validate_reset_token
    token = password_reset_params[:reset_password_token]
    
    unless token.present?
      render json: {
        error: "Password reset token is required"
      }, status: :unprocessable_entity
      return false
    end
    
    user = User.with_reset_password_token(token)
    unless user&.reset_password_period_valid?
      render json: {
        error: "Password reset token is invalid or has expired"
      }, status: :unprocessable_entity
      return false
    end
  end
end
