class TrelloAccountsController < ApplicationController
  respond_to :html, :json

  def new
    @trello_account = TrelloAccount.new
  end

  def create
    @trello_account = TrelloAccount.create(params[:trello_account])
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
      ta.token  = @access_token.token
      ta.secret = @access_token.secret
    end
    redirect_to new_project_path(trello_account_id: @trello_account.id)
  end

  private

  def callback_url
    callback_trello_accounts_url
  end

  def app_name
    "Bottleneck (#{Rails.env.titleize})"
  end

  def consumer
    @consumer ||= ::OAuth::Consumer.new(ENV['TRELLO_USER_KEY'], ENV['TRELLO_USER_SECRET'],
                     site:                'https://trello.com',
                     request_token_path:  '/1/OAuthGetRequestToken',
                     authorize_path:      '/1/OAuthAuthorizeToken',
                     access_token_path:   '/1/OAuthGetAccessToken',
                     http_method:         :get)
  end

  def access_token
    @access_token ||= begin
      return nil unless token = request.cookies["access_token"]
      Marshal.load(redis.get(token))
    end
  end

  def request_token
    @request_token ||= begin
      if session[:request_token] && session[:request_token_secret]
        ::OAuth::RequestToken.new(consumer, session[:request_token], session[:request_token_secret])
      else
        rtoken = consumer.get_request_token(:oauth_callback => callback_url)
        session[:request_token] = rtoken.token
        session[:request_token_secret] = rtoken.secret
        rtoken
      end
    end
  end

  def oauth_verify!(oauth_verifier)
    atoken = request_token.get_access_token(:oauth_verifier => oauth_verifier)

    store_access_token! atoken

    atoken
  end

  def oauth_verified?
    !access_token.nil?
  end

  def store_access_token!(atoken)
    # Request token is invalidated after retrieving access_token
    session.clear

    token_key = atoken.token
    @access_token = nil

    response.set_cookie "access_token", token_key
    redis.set token_key, Marshal.dump(atoken)
  end

end
