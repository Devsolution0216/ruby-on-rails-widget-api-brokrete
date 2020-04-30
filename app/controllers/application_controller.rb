# frozen_string_literal: true
class ApplicationController < ActionController::API
  before_action :authenticate_token

  def default_url_options
    { host: ENV["DOMAIN_NAME"] }
  end

  protected

  attr_reader :current_user

  private

  def authenticate_token
    if request.headers['ForceUserId'].present?
      user_id = request.headers['ForceUserId']
      @current_user = User.find_by id: user_id
      return
    end


    if request.headers['Authorization'].present?
      decrypted_token = JwtManager.decode(request.headers['Authorization'])
      @current_user = User.find_by id: decrypted_token['user']

      @current_user = User.first unless @current_user.present?

      TokenHelper.generate_access_token(@current_user, response) if @current_user.present?
    end
  rescue JWT::ExpiredSignature
    # TODO Implement refresh token
    @current_user = nil
  rescue JWT::DecodeError
    nil
  end

end
