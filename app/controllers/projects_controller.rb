class ProjectsController < ApplicationController
  check_authorization

  before_filter :find_project, only: [:show, :edit, :update, :refresh, :clear]
  around_filter :project_time_zone, only: [:show, :edit, :update, :refresh, :clear],
    if: :current_project
  before_filter :build_trello_account, only: [:new, :create]

  respond_to :html, :json

  def show
    authorize! :read, @project

    @flow = CumulativeFlow.new(
      start_time: 14.days.ago,
      end_time: Clock.time,
      project: @project
    )
    @range = @flow.dates
  end

  def new
    authorize! :create, Project
  end

  def create
    authorize! :create, Project

    form = ProjectForm.new(params[:project]) do |p|
      p.trello_account = @trello_account
      p.owner = current_user
    end

    if form.save
      flash[:notice] = "Your project was successfully imported."
      session[:trello_account_id] = nil
    end
    @project = form.project
    respond_with @project
  end

  def edit
    @project = Project.find(params[:id])
    authorize! :update, @project

  end

  def update
    @project = Project.find(params[:id])
    authorize! :update, @project

    form = ProjectForm.new(params[:project])
    form.project = @project
    if form.save
      flash[:notice] = "Your project was successfully updated."
    end

    respond_with @project
  end

  def refresh
    @project = Project.find(params[:id])
    authorize! :update, @project

    @project.fetch
    @project.save
    respond_with @project
  end

  def clear
    session.delete(:trello_account_id)
    redirect_to root_url
  end

  protected

  def find_project
    @project ||= Project.find(params[:id])
  end

  def build_trello_account
    if trello_account_id = (session[:trello_account_id] || params[:trello_account_id])
      session[:trello_account_id] = trello_account_id
      @trello_account = TrelloAccount.find(trello_account_id)
    else
      flash[:notice] = "Please connect to your Trello account first"
      redirect_to start_project_path
    end
  end

end
