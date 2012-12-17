class ApplicationController < ActionController::Base
  protect_from_forgery

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  # Public - devise override
  alias_method :devise_current_user, :current_user
  def current_user
    @current_user ||= devise_current_user || AnonymousUser.new
  end

  # Public - devise override
  def user_signed_in?
    !!devise_current_user
  end

  def anonymous_user?
    !user_signed_in?
  end

  # # Public - devise override
  # def sign_in(resource_or_scope, *args)
  #   super
  #   finish_flow
  # end

  # # Public - devise override
  # def after_sign_in_path_for(scope)
  #   case scope
  #   when User
  #     current_flow.destination || super
  #   else
  #     super
  #   end
  # end

end
