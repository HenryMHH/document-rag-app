# use for api authentication
module ApiAuthentication
  extend ActiveSupport::Concern

  included do
    helpers do
      def current_user
        @current_user ||= authenticate_user
      end

      def authenticate_user
        # 方法 1: 檢查 Authorization header (推薦用於 API 調用)
        if request.headers["Authorization"]
          token = request.headers["Authorization"].split(" ").last
          return decode_access_token(token)
        end

        # 方法 2: 檢查 cookies 中的 refresh token (用於瀏覽器)
        return decode_refresh_token(cookies[:lt_agent_rt]) if cookies[:lt_agent_rt].present?

        nil
      end

      def decode_access_token(token)
        decoded = JWT.decode(token, ENV["APP_JWT_SECRET"], true, { algorithm: "HS256" })
        user_id = decoded[0]["user_id"]
        User.find(user_id)
      rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound => e
        Rails.logger.error "Access token decode error: #{e.message}"
        nil
      end

      def decode_refresh_token(token)
        decoded = JWT.decode(token, ENV["APP_JWT_SECRET"], true, { algorithm: "HS256" })
        refresh_token_jti = decoded[0]["jti"]
        User.find_by(active_refresh_token_jti: refresh_token_jti)
      rescue JWT::DecodeError, JWT::ExpiredSignature => e
        Rails.logger.error "Refresh token decode error: #{e.message}"
        nil
      end

      def authenticate_user!
        user = current_user
        error!({ error: "Unauthorized" }, 401) unless user
        user
      end
    end
  end
end
