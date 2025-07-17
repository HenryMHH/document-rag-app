# use for api authentication
module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    helpers do
      def current_user
        @current_user ||= authenticate_user
      end

      def authenticate_user
        access_token = request.headers["Authorization"]&.split(" ")&.last
        raise NoAccessTokenError unless access_token

        decoded = JwtService.decode(access_token)
        user_id = decoded[0]["user_id"]
        User.find(user_id)
      rescue JWT::ExpiredSignature, NoAccessTokenError
        error!({ code: "ACCESS_TOKEN_EXPIRED" }, 401) if refresh_token_valid?(cookies[:lt_agent_rt])
      end

      def refresh_token_valid?(token)
        payload = JwtService.decode(token)
        user_id = payload[0]["user_id"]
        jti = payload[0]["jti"]

        user = User.find_by(id: user_id)

        user.active_refresh_token_jti == jti
      rescue StandardError
        false
      end

      def authenticate_user!
        user = current_user
        error!({ code: "UNAUTHORIZED" }, 401) unless user
        user
      end
    end
  end
end

# Error classes for different token states
class NoAccessTokenError < StandardError
  def initialize(message = "No access token")
    super(message)
  end
end
