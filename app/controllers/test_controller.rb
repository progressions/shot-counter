# Test helper controller for E2E testing
# Only available in test environment
class TestController < ApplicationController
  # Skip authentication for test endpoints
  skip_before_action :authenticate_user!
  
  # Only allow in test environment
  before_action :ensure_test_environment
  
  # Get reset password token for E2E testing
  # POST /test/get_reset_token
  def get_reset_token
    email = params[:email]
    
    if email.blank?
      render json: { error: 'Email is required' }, status: 400
      return
    end
    
    user = User.find_by(email: email)
    
    if user.nil?
      render json: { error: 'User not found' }, status: 404
      return
    end
    
    # Check if user has a reset token
    if user.reset_password_token.present?
      # Return the raw token (not the encrypted version)
      render json: { 
        reset_password_token: user.reset_password_token,
        email: user.email,
        message: 'Reset token retrieved successfully'
      }
    else
      render json: { 
        error: 'No reset token found for user. Request password reset first.',
        email: user.email
      }, status: 404
    end
    
  rescue => error
    render json: { error: error.message }, status: 500
  end
  
  # Clear reset token for testing
  # POST /test/clear_reset_token  
  def clear_reset_token
    email = params[:email]
    
    if email.blank?
      render json: { error: 'Email is required' }, status: 400
      return
    end
    
    user = User.find_by(email: email)
    
    if user.nil?
      render json: { error: 'User not found' }, status: 404
      return
    end
    
    user.update!(reset_password_token: nil, reset_password_sent_at: nil)
    
    render json: { 
      message: 'Reset token cleared successfully',
      email: user.email 
    }
    
  rescue => error
    render json: { error: error.message }, status: 500
  end
  
  private
  
  def ensure_test_environment
    unless Rails.env.test?
      render json: { error: 'Test endpoints only available in test environment' }, status: 403
    end
  end
end