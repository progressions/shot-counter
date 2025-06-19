module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      reject_unauthorized_connection unless current_user
    end

    private

    def find_verified_user
      Rails.logger.info("SOCKETS - Attempting to verify user connection: #{request.inspect}")
      Rails.logger.info("SOCKETS - Attempting to verify user connection: #{request.params.inspect}")
      token = request.params[:token]
      return unless token

      Rails.logger.info("SOCKETS - Attempting to verify user with token: #{token}")

      begin
        # Assumes devise-jwt with a payload like { "jti", "sub" }
        jwt_payload = JWT.decode(
          token.split(' ')[1],
          Rails.application.credentials.devise_jwt_secret_key!
        ).first

        User.find_by(id: jwt_payload['sub']) # 'sub' is typically the user ID
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        Rails.logger.error "JWT verification failed: #{e.message}"
        nil
      end
    end
  end
end
