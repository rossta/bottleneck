class Api::V1::OutputsController < Api::V1::ApiController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  def show
    authorize! :read, @project
    @output = Output.new(@project)
    render json: @output
  end

end
