class ListsController < ApplicationController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  respond_to :html, :json

  def show
    @list = @project.lists.find(params[:id])
  end

  def update
    @list = List.find(params[:id])
    Rails.logger.info @list.update_attributes(params[:list])

    render json: @list
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end

end
