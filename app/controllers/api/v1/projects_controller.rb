class Api::V1::ProjectsController < Api::V1::ApiController
  def index
    authorize! :read, current_user
    @projects = current_user.projects
    render json: @projects
  end

  def show
    @project = current_user.projects.find(params[:id])
    authorize! :read, @project
    render json: @project
  end

  def summary
    @project = current_user.projects.find(params[:id])
    @summary = ProjectSummary.new(@project)
    render json: @summary
  end
end
