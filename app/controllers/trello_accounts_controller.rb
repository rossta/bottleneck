class TrelloAccountsController < ApplicationController
  respond_to :html, :json

  def new
    @trello_account = TrelloAccount.new
  end

  def create
    @trello_account = TrelloAccount.create(params[:trello_account]) do |ta|
      ta.user = current_user
    end
    session[:trello_account_id] = @trello_account.id if @trello_account.persisted?
    respond_with @trello_account, location: new_project_path
  end

  def authorize
    redirect_to request_token.authorize_url(:oauth_callback => callback_url, name: app_name)
  end

  def callback
    Rails.logger.info "callback received..................."
    Rails.logger.info params.inspect
    @access_token = request_token.get_access_token(oauth_verifier: params[:oauth_verifier])
    @trello_account = TrelloAccount.create do |ta|
      ta.user   = current_user
      ta.token  = @access_token.token
      ta.secret = @access_token.secret
    end
    expire_request_token!
    redirect_to new_project_path(trello_account_id: @trello_account.id)
  end

  private

  def callback_url
    callback_trello_accounts_url
  end

  def app_name
    Rails.application.config.app_name
  end

  def consumer
    @consumer ||= ::OAuth::Consumer.new(ENV['TRELLO_USER_KEY'], ENV['TRELLO_USER_SECRET'],
                     site:                'https://trello.com',
                     request_token_path:  '/1/OAuthGetRequestToken',
                     authorize_path:      '/1/OAuthAuthorizeToken',
                     access_token_path:   '/1/OAuthGetAccessToken',
                     http_method:         :get)
  end

  def request_token
    @request_token ||= begin
      if session[:request_token] && session[:request_token_secret]
        ::OAuth::RequestToken.new(consumer, session.delete(:request_token),
          session.delete(:request_token_secret))
      else
        rtoken = consumer.get_request_token(:oauth_callback => callback_url)
        session[:request_token] = rtoken.token
        session[:request_token_secret] = rtoken.secret
        rtoken
      end
    end
  end

  def expire_request_token!
    session.delete(:request_token)
    session.delete(:request_token_secret)
  end

end
