class Api::V1::ApiController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_filter :restrict_access

  respond_to :json

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_to do |format|
      format.json { render :text => exception.to_json, :status => :not_found }
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.js { render json: exception.to_json, status: :unauthorized }
    end
  end

  protected

  # vnd.example-com.foo+json; version=1.0
  # application/vnd.steveklabnik-v2+json
  def restrict_access
    authenticate_user!
    # raise CanCan::AccessDenied unless current_user.persisted?

    # @current_user = authenticate_with_http_token do |token, options|
    #   Rails.logger.info("authenticating... #{token}, #{options}")
    #   User.find_by_authentication_token(token)
    # end
    # raise CanCan::AccessDenied unless @current_user
  end

end
