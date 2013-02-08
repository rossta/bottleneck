class Api::V1::CumulativeFlowsController < Api::V1::ApiController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
    authorize! :read, @project
    @flow = CumulativeFlow.new(@project,
      start_time: (end_time - 14.days),
      end_time: end_time,
      collapsed: !!params[:collapsed]
    )

    render json: @flow
  end

  def find_project
    @project = current_user.projects.find(params[:id])
  end

  def end_time
    @end_time ||= Clock.time
  end
end
