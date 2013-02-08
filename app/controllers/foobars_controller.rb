class FoobarsController < ApplicationController

  def show
    Rails.logger.info "Foobar"
    Rails.logger.info "referer: #{request.referer}"
    head :ok
  end
end
