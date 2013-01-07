class ProjectsController < ApplicationController
  before_filter :build_trello_account, only: [:new, :create]

  respond_to :html, :json

  def new
    @trello_boards = @trello_account.trello_boards
  end

  def create
    @project = Project.new(params[:project])
    @project.trello_account = @trello_account

    @project.owner = current_user if user_signed_in?

    if @project.save && @project.fetch
      flash[:notice] = "Your project was successfully created."
      session[:trello_account_id] = nil
    end

    Rails.logger.info @project.inspect
    respond_with @project
  end

  def refresh
    @project = Project.find(params[:id])
    @project.fetch
    @project.save
    respond_with @project
  end

  def show
    @project = Project.find(params[:id])
  end

  def clear
    session.delete(:trello_account_id)
    redirect_to root_url
  end

  protected

  def build_trello_account
    if session[:trello_account_id]
      @trello_account = TrelloAccount.find(session[:trello_account_id])
    else
      flash[:notice] = "Please connect to your Trello account first"
      redirect_to start_project_path
    end
  end

end
