class Api::V1::ProjectsController < Api::V1::ApiController
  before_filter :find_project, except: [:index]
  around_filter :project_time_zone, if: :current_project

  def index
    authorize! :read, current_user
    @projects = current_user.projects
    render json: @projects
  end

  def show
    authorize! :read, @project
    render json: @project
  end

end
