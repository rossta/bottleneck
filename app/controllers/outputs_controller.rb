class OutputsController < ApplicationController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
    @output = Output.new(
      start_time: 14.days.ago,
      end_time: Clock.time,
      project: @project
    )
  end

  def edit
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end
end