class HomeController < ApplicationController
  def index
    redirect_to new_user_registration_path unless Rails.application.config.enable_homepage
  end
end
