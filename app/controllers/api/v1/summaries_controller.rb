class Api::V1::SummariesController < Api::V1::ApiController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
    authorize! :read, @project
    @summary = Summary.new(@project)
    render json: @summary
  end

end
