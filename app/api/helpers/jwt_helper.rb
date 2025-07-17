# frozen_string_literal: true

require "jwt"

# JWT Helper
module JwtHelper
  ACCESS_TOKEN_EXPIRY = 15.minutes
  REFRESH_TOKEN_EXPIRY = 7.days

  def generate_token_pair(user)
    at_exp = Time.now.to_i + ACCESS_TOKEN_EXPIRY
    rt_exp = Time.now.to_i + REFRESH_TOKEN_EXPIRY
    refresh_token_jti = SecureRandom.uuid
    access_token = JwtService.encode({
                                       user_id: user.id,
                                       exp: at_exp
                                     })
    refresh_token = JwtService.encode({
                                        user_id: user.id,
                                        jti: refresh_token_jti,
                                        exp: rt_exp
                                      })
    user.update!(active_refresh_token_jti: refresh_token_jti)
    set_refresh_token_cookie(refresh_token, rt_exp)
    {
      access_token: access_token,
      refresh_token: refresh_token
    }
  end

  def set_refresh_token_cookie(refresh_token, expiry)
    cookie_options = {
      httponly: true,
      path: "/",
      expires: Time.at(expiry)
    }
    if Rails.env.production?
      cookie_options[:secure] = true
      cookie_options[:same_site] = "None"
    else
      cookie_options[:same_site] = "Lax"
    end
    cookies[:lt_agent_rt] = {
      value: refresh_token,
      **cookie_options
    }
  end

  def clear_refresh_token_cookie
    cookies.delete(:lt_agent_rt,
                   path: "/",
                   secure: Rails.env.production?,
                   same_site: Rails.env.production? ? "None" : "Lax")
  end
end
