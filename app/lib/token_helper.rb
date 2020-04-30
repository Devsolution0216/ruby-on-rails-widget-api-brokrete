class TokenHelper
  def self.generate_access_token(user, response)
    token = JwtManager.issue_with_expiration({ user: user.id })
    unless Rails.env.test?
      response.set_header 'Authorization', token
      response.set_header 'Expires', JwtManager.token_expiration(token)
    end
    token
  end
end
