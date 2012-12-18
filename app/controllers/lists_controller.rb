class ListsController < ApplicationController

  respond_to :html, :json

  def update
    @list = List.find(params[:id])
    Rails.logger.info @list.update_attributes(params[:list])

    render json: @list
  end

end
