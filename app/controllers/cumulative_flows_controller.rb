class CumulativeFlowsController < ApplicationController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
    @flow = CumulativeFlow.new(@project,
      start_time: 14.days.ago,
      end_time: Clock.time,
      collapsed: !!params[:collapsed]
    )
  end

  def edit
  end

  protected

  def find_project
    @project = Project.find(params[:project_id])
  end

end
