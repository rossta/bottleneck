class BreakdownsController < ApplicationController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
  end

  def edit
  end

  protected

  def find_project
    @project = current_user.projects.find(params[:project_id])
  end
end
