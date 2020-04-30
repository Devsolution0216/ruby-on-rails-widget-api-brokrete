require 'jwt'

class JwtManager
  ALGORITHM = 'HS256'
  TYPE = 'Bearer'

  class << self
    def issue_with_expiration(payload, custom_expiration = nil)
      if custom_expiration.present? && custom_expiration.is_a?(ActiveSupport::Duration)
        payload[:exp] = custom_expiration
      else
        payload.merge!(expiration)
      end

      issue payload
    end

    def issue(payload)
      token = JWT.encode payload,
        auth_secret,
        ALGORITHM
      set_type token
    end

    def token_expiration(token)
      decrypted_token = decode(token)
      decrypted_token.try(:[], 'exp')
    end

    def decode(token)
      token = extract_token token
      decrypted_token = JWT.decode token,
        auth_secret,
        true,
        { algorithm: ALGORITHM }
      decrypted_token.first
    end

    private

    def auth_secret
      ENV["SECRET_KEY"]
    end

    def set_type(token)
      "#{TYPE} #{token}"
    end

    def extract_token(token)
      token.gsub "#{TYPE} ", ''
    end

    def expiration
      exp = Time.now.to_i + 1.day
      { exp: exp }
    end

    alias_method :issue_without_expiration, :issue
  end
end

