class Api::V1::UsersController < Api::V1::ApiController
  def show
    @user = User.find(params[:id])
    authorize! :read, @user
    render json: @user
  end

  def me
    authorize! :read, current_user
    render json: current_user
  end
end
