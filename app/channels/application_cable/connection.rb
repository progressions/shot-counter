module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

    def find_verified_user
      Rails.logger.info("SOCKETS - Attempting to verify user connection")
      Rails.logger.info("SOCKETS - Request params: #{request.params.inspect}")
      
      token = request.params[:token]
      return unless token

      Rails.logger.info("SOCKETS - Token received: #{token[0..50]}...") # Log first 50 chars for security

      begin
        # Handle both "Bearer token" format and plain token
        actual_token = token.start_with?('Bearer ') ? token.split(' ')[1] : token
        
        # Decode JWT with devise-jwt secret
        jwt_payload = JWT.decode(
          actual_token,
          Rails.application.credentials.devise_jwt_secret_key!,
          true,
          algorithm: 'HS256'
        ).first

        Rails.logger.info("SOCKETS - JWT decoded successfully, user_id: #{jwt_payload['sub']}")
        
        user = User.find_by(id: jwt_payload['sub'])
        if user
          Rails.logger.info("SOCKETS - User found: #{user.email}")
        else
          Rails.logger.warn("SOCKETS - User not found for ID: #{jwt_payload['sub']}")
        end
        
        user
      rescue JWT::DecodeError => e
        Rails.logger.error "SOCKETS - JWT decode error: #{e.message}"
        nil
      rescue JWT::ExpiredSignature => e
        Rails.logger.error "SOCKETS - JWT expired: #{e.message}"
        nil
      rescue StandardError => e
        Rails.logger.error "SOCKETS - Unexpected error: #{e.class} - #{e.message}"
        nil
      end
    end
  end
end
