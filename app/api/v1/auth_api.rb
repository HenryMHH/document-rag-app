require_relative "../../services/google_oauth_client"

module V1
  # Auth api
  class AuthApi < BaseApi
    resource :auth do
      # code is auth code from google
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

        # Generate token pair
        tokens = generate_token_pair(user)

        {
          message: "Successfully logged in",
          user: user.as_json(only: %i[id name email avatar_url]).merge(role: user.role.name),
          access_token: tokens[:access_token]
        }
      end

      post "refresh" do
        refresh_token = cookies[:lt_agent_rt]
        raise "INVALID_REFRESH_TOKEN" if refresh_token.blank?

        rt_payload = JwtService.decode(refresh_token)
        refresh_token_jti = rt_payload[0]["jti"]
        user_id = rt_payload[0]["user_id"]
        user = User.find_by(id: user_id, active_refresh_token_jti: refresh_token_jti)
        raise "INVALID_REFRESH_TOKEN" if user.blank?

        user.update!(active_refresh_token_jti: nil)
        tokens = generate_token_pair(user)

        {
          access_token: tokens[:access_token]
        }
      rescue StandardError => e
        error!({
                 code: e
               }, 401)
      end
    end
  end
end
