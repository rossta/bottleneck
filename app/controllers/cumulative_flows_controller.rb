class CumulativeFlowsController < ApplicationController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def edit
  end

  def show
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end

end
