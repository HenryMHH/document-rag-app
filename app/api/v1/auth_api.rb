require_relative "../../services/google_oauth_client"

module V1
  # Auth api
  class AuthApi < BaseApi
    resource :auth do
      params do
        requires :code, type: String
      end
      post "google" do
        client_id = ENV["GOOGLE_CLIENT_ID"]
        client_secret = ENV["GOOGLE_CLIENT_SECRET"]
        redirect_uri = ENV["GOOGLE_REDIRECT_URI"]

        oauth_client = GoogleOAuthClient.new(nil)

        token_data = oauth_client.exchange_code_for_tokens(params[:code], redirect_uri, client_id, client_secret)

        access_token = token_data[:access_token]

        user_info_client = GoogleOAuthClient.new(access_token)
        user_info = user_info_client.get_user_info

        unless user_info
          render json: { error: "Failed to retrieve user info from Google" }, status: :unprocessable_entity and return
        end

        user = User.find_or_initialize_by(email: user_info[:email])

        user.provider = "google"
        user.uid = user_info[:sub]
        user.name = user_info[:name]
        user.email = user_info[:email]
        user.avatar_url = user_info[:picture]
        user.role_id = Role.find_by(name: "user").id

        user.save!

        app_jwt_secret = ENV["APP_JWT_SECRET"]
        at_exp = Time.now.to_i + 15 * 60 # Access Token 15 分鐘過期
        rt_exp = Time.now.to_i + 7 * 24 * 3600 # Refresh Token 7 天過期
        refresh_token_jti = SecureRandom.uuid

        access_token = JWT.encode({ user_id: user.id, exp: at_exp }, app_jwt_secret, "HS256")
        refresh_token = JWT.encode({ user_id: user.id, jti: refresh_token_jti, exp: rt_exp }, app_jwt_secret, "HS256")

        user.update!(active_refresh_token_jti: refresh_token_jti)

        # 設置 Cookie 屬性
        cookie_options = {
          httponly: true,
          path: "/",
          expires: Time.at(rt_exp)
        }

        # 根據環境設置 Secure 和 SameSite
        if Rails.env.production?
          cookie_options[:secure] = true
          cookie_options[:same_site] = "None"
        else
          cookie_options[:same_site] = "Lax"
        end

        # 使用 Grape 的 cookies 方法設置 cookie
        cookies[:lt_agent_rt] = {
          value: refresh_token,
          **cookie_options
        }

        {
          message: "Successfully logged in",
          user: user.as_json(only: %i[id name email avatar_url]).merge(role: user.role.name),
          access_token: access_token
        }
      end

      post "refresh" do
        refresh_token = cookies[:lt_agent_rt]

        error!({ error: "Refresh token not found" }, 401) if refresh_token.blank?

        app_jwt_secret = ENV["APP_JWT_SECRET"]

        begin
          decoded_token = JWT.decode(refresh_token, app_jwt_secret, true, { algorithm: "HS256" })
          refresh_token_jti = decoded_token[0]["jti"]
        rescue JWT::DecodeError => e
          error!({ error: "Invalid refresh token" }, 401)
        end

        user = User.find_by(active_refresh_token_jti: refresh_token_jti)

        error!({ error: "User not found" }, 401) if user.blank?

        at_exp = Time.now.to_i + 15 * 60

        access_token = JWT.encode({ user_id: user.id, exp: at_exp }, app_jwt_secret, "HS256")

        {
          access_token: access_token
        }
      end
    end
  end
end
