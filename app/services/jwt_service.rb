# app/services/jwt_service.rb
class JwtService
  JWT_ALGORITHM = "HS256".freeze

  def self.encode(payload)
    JWT.encode(payload, jwt_secret, JWT_ALGORITHM)
  end

  def self.decode(token)
    JWT.decode(token, jwt_secret, true, { algorithm: JWT_ALGORITHM })
  end

  def self.extract_payload(token)
    decoded = decode(token)
    decoded[0] # 返回 payload 部分
  rescue JWT::DecodeError => e
    Rails.logger.warn "JWT decode error: #{e.message}"
    nil
  end

  def self.jwt_secret
    @jwt_secret ||= ENV["APP_JWT_SECRET"]
  end

  private_class_method :jwt_secret
end
