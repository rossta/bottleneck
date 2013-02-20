class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter { Rails.logger.info "return_url: #{session[:user_return_url]}"}

  rescue_from CanCan::AccessDenied do |exception|
    respond_to do |format|
      format.html { redirect_to root_path, :alert => exception.message }
      format.js { render json: exception.to_json, status: :unauthorized }
    end
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

  def current_ability
    Ability.new(current_user)
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

  def find_project
    @project = current_user.projects.find(params[:id])
  end

  def find_project_nested
    @project = current_user.projects.find(params[:project_id])
  end

  def current_project
    @project
  end

  def project_time_zone(&block)
    Time.use_zone(current_project.time_zone, &block)
  end

  # Public - devise override
  def after_sign_in_path_for(resource_or_scope)
    dashboard_path
  end

  # Public - devise override
  def after_sign_up_path_for(resource_or_scope)
    start_project_path
  end

end
