module V1
  # User api
  class UserApi < BaseApi
    resource :user do
      desc "Get user"
      get "/info" do
        refresh_token = cookies[:lt_agent_rt]

        puts cookies
        puts "refresh_token: #{refresh_token}"

        if refresh_token.blank?
          render json: { error: "Refresh token not found" }, status: :unprocessable_entity and return
        end

        app_jwt_secret = ENV["APP_JWT_SECRET"]

        refresh_token_jti = JWT.decode(refresh_token, app_jwt_secret, true, { algorithm: "HS256" })[0]["jti"]

        user = User.find_by(active_refresh_token_jti: refresh_token_jti)

        render json: { error: "User not found" }, status: :unprocessable_entity and return if user.blank?

        user
      end
    end

    private

    def current_user
      refresh_token = cookies[:lt_agent_rt]

      puts "refresh_token: #{refresh_token}"

      if refresh_token.blank?
        render json: { error: "Refresh token not found" }, status: :unprocessable_entity and return
      end

      app_jwt_secret = ENV["APP_JWT_SECRET"]

      refresh_token_jti = JWT.decode(refresh_token, app_jwt_secret, true, { algorithm: "HS256" })[0]["jti"]

      user = User.find_by(active_refresh_token_jti: refresh_token_jti)

      render json: { error: "User not found" }, status: :unprocessable_entity and return if user.blank?

      user
    end
  end
end
