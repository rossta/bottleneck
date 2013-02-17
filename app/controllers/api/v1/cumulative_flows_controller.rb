class Api::V1::CumulativeFlowsController < Api::V1::ApiController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
    authorize! :read, @project
    @date_range = DateRange.new(
      start_time: (end_time - 14.days),
      end_time: end_time,
    )
    @flow = CumulativeFlow.new(@project,
      date_range: @date_range,
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
