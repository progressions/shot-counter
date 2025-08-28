# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  respond_to :json

  # before_action :configure_sign_in_params, only: [:create]

  # POST /resource/sign_in
  def create
    # Log only the email, never the password
    Rails.logger.info("Login attempt for email: #{sign_in_params[:email]}")
    @user = User.find_by(email: sign_in_params[:email])
    if @user && @user.valid_password?(sign_in_params[:password])
      sign_in(:user, @user)
      
      # Generate JWT token for the response header
      jwt_token = JWT.encode(
        @user.jwt_payload,
        Rails.application.credentials.devise_jwt_secret_key!,
        'HS256'
      )
      
      # Set Authorization header for frontend
      response.headers['Authorization'] = "Bearer #{jwt_token}"

      render json: {
        code: 200,
        message: 'User signed in successfully',
        data: @user,
        payload: @user.jwt_payload
      }
    else
      render json: {
        status: 401,
        message: 'Invalid email or password'
      }, status: :unauthorized
    end
  end

  private

  def respond_with(resource, options={})
    # Generate JWT token for the response header
    jwt_token = JWT.encode(
      current_user.jwt_payload,
      Rails.application.credentials.devise_jwt_secret_key!,
      'HS256'
    )
    
    # Set Authorization header for frontend
    response.headers['Authorization'] = "Bearer #{jwt_token}"
    
    render json: {
      code: 200,
      message: 'User signed in successfully',
      data: current_user,
      payload: current_user.jwt_payload
    }
  end

  def respond_to_on_destroy
    jwt_payload = JWT.decode(
      request.headers['Authorization'].split(' ')[1],
      Rails.application.credentials.devise_jwt_secret_key!
    ).first

    current_user = User.find(jwt_payload['sub'])
    if current_user
      render json: {
        status: 200,
        message: 'Signed out successfully'
      }
    else
      render json: {
        status: 401,
        message: 'User has no active session'
      }, status: :unauthorized
    end
  end

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end

  def sign_in_params
    params.require(:user).permit(:email, :password)
  end
end
