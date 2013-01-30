class HomeController < ApplicationController
  def index
    redirect_to new_user_registration_path if Rails.application.config.disable_homepage
  end
end
