class Api::V1::ProjectsController < Api::V1::ApiController

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
