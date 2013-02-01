class Api::V1::ApiController < ApplicationController
  before_filter :restrict_access
  before_filter

  respond_to :json

  protected

  def restrict_access
    Rails.logger.info request.headers['Accept']
    Rails.logger.info request.headers['Authorization']
    authenticate_or_request_with_http_token do |token, options|
      Rails.logger.info token
      token == 'foobar'
    end
  end

end
