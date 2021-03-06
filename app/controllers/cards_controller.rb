class CardsController < ApplicationController
  before_filter :find_project
  around_filter :project_time_zone, if: :current_project

  respond_to :html, :json

  def show
    @card = @project.cards.find(params[:id])
  end

end
