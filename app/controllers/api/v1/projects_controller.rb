class Api::V1::ProjectsController < ApplicationController

  def index
    @projects = current_user.projects
    authorize! :read, @projects
    render json: @projects
  end

  def show
    authorize! :read, @project
    render json: @project
  end

end
