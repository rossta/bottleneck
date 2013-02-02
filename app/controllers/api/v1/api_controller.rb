class Api::V1::ApiController < ApplicationController
  before_filter :restrict_access

  respond_to :json

  protected

  # vnd.example-com.foo+json; version=1.0
  # application/vnd.steveklabnik-v2+json
  def restrict_access
    @current_user = authenticate_with_http_token do |token, options|
      Rails.logger.info("authenticating... #{token}, #{options}")
      User.find_by_authentication_token(token)
    end
  end

  def current_user
    @current_user
  end
end
