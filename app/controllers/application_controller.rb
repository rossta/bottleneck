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
  def current_user_with_anonymous
    current_user_without_anonymous || AnonymousUser.new
  end
  alias_method_chain :current_user, :anonymous

  # Public - devise override
  def user_signed_in?
    !!current_user_without_anonymous
  end

  def anonymous_user?
    !user_signed_in?
  end

  def current_ability
    Ability.new(current_user, preview: project_preview?)
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
    @project = current_user.find_project(params[:project_id] || params[:id], preview_token)
  end

  def current_project
    @project
  end

  def project_preview?
    current_project && preview_token && project_preview_token == preview_token
  end
  helper_method :project_preview?

  def project_preview_token
    @project_preview_token ||= PreviewToken.new(current_project)
  end

  def preview_token
    return session[:preview] if params[:preview].blank?
    params[:preview].tap do |preview|
      session[:preview] = preview
    end
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
