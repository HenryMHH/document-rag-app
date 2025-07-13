# app/services/google_oauth_client.rb (建議放在 app/services 或 app/lib)

require "faraday"
require "json" # Faraday 可以自動解析 JSON，但手動處理時可能需要

class GoogleOAuthClient
  # Google UserInfo API 的基礎 URL
  BASE_URL = "https://www.googleapis.com/oauth2/v3/"

  def initialize(access_token)
    @access_token = access_token
    # 初始化 Faraday 連接
    @connection = Faraday.new(url: BASE_URL) do |faraday|
      # 設定請求頭
      faraday.headers["Authorization"] = "Bearer #{@access_token}"
      faraday.headers["Content-Type"] = "application/json"
      faraday.headers["Accept"] = "application/json"

      # 設定中介軟體 (Middleware)
      # faraday.request :json                               # 自動將請求 body 轉換為 JSON
      faraday.response :json, parser_options: { symbolize_names: true }, content_type: /\bjson$/ # 自動解析 JSON 回傳，並將 key 轉為 symbol
      faraday.response :raise_error # 處理 HTTP 錯誤 (例如 4xx, 5xx)
      faraday.response :logger, Rails.logger, { headers: true, bodies: true } # 日誌記錄請求和回應

      # 使用預設的 HTTP 適配器 (Net::HTTP)
      faraday.adapter Faraday.default_adapter
    end
  end

  # 獲取當前 access_token 對應的用戶資訊
  def get_user_info
    response = @connection.get("userinfo") # 相對於 BASE_URL 的路徑
    # Faraday 的 :raise_error 中介軟體會自動拋出異常，如果響應不是 2xx
    response.body # 如果有 :json response 中介軟體，這會是一個 Ruby Hash
  rescue Faraday::Error => e
    Rails.logger.error "Error fetching Google user info: #{e.message}"
    Rails.logger.error "Response body: #{e.response[:body]}" if e.response
    nil # 或者重新拋出一個自定義異常
  end

  # 範例：交換授權碼為 access token (更底層的請求)
  # 這個方法在你的 SessionsController 中可能會用到，如果不想直接寫 Net::HTTP
  def exchange_code_for_tokens(code, redirect_uri, client_id, client_secret)
    token_connection = Faraday.new(url: "https://oauth2.googleapis.com") do |faraday|
      faraday.request :url_encoded # 表單提交
      faraday.response :json, parser_options: { symbolize_names: true }, content_type: /\bjson$/
      faraday.response :raise_error
      faraday.adapter Faraday.default_adapter
    end

    response = token_connection.post("token", {
                                       client_id: client_id,
                                       client_secret: client_secret,
                                       code: code,
                                       redirect_uri: redirect_uri,
                                       grant_type: "authorization_code"
                                     })

    response.body # 返回包含 access_token, id_token 等的 Hash
  rescue Faraday::Error => e
    Rails.logger.error "Error exchanging Google code for tokens: #{e.message}"
    Rails.logger.error "Response body: #{e.response[:body]}" if e.response
    raise # 重新拋出異常讓調用者處理
  end
end
