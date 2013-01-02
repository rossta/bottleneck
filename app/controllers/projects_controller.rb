class ProjectsController < ApplicationController
  before_filter :build_trello_account, only: [:start, :new, :create]
  before_filter :redirect_to_new, only: :start
  before_filter :redirect_to_start, only: :new

  respond_to :html, :json

  def start
  end

  def new
    @trello_boards = @trello_account.trello_boards
  end

  def create
    @project = Project.new(params[:project])
    @project.trello_account = @trello_account

    @project.owner = current_user if user_signed_in?

    if @project.save && @project.fetch
      flash[:notice] = "Your project was successfully created."
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
    @trello_account = if trello_account_id = session[:trello_account_id]
      TrelloAccount.find(trello_account_id)
    else
      TrelloAccount.new
    end
  end

  def redirect_to_new
    if @trello_account.persisted?
      redirect_to new_project_path
      return
    end
  end

  def redirect_to_start
    if @trello_account.new_record?
      redirect_to start_project_path
      return
    end
  end
end
