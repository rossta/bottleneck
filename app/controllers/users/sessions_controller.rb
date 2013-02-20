class Users::SessionsController < Devise::SessionsController
  after_filter :store_location, only: [:new]

  protected

  def store_location
    session[:user_return_to] = request.referrer
  end
end
