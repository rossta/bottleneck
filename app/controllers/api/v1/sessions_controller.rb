class Api::V1::SessionsController < Api::V1::ApiController
  prepend_before_filter :allow_params_authentication!, :only => :create
  skip_before_filter :restrict_access, only: [:create]

  def create
    @user = warden.authenticate!(scope: :user)
    @user.reset_authentication_token!
    render json: @user
  end

  def destroy
    current_user.authentication_token = nil
    current_user.save(validate: false)
    head :ok
  end
end
