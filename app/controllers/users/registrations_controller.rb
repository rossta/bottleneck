class Users::RegistrationsController < Devise::RegistrationsController

  # Public - devise override
  def after_sign_up_path_for(resource)
    start_project_path
  end
end
