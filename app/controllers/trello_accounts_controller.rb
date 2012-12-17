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
    TrelloAuthorization.create_trello_account callback_trello_accounts_url do |request_token|
      Rails.logger.info "Request token received: key, secret"
      Rails.logger.info request_token.inspect
      Rails.logger.info [request_token.token, request_token.secret].join(', ')
      @trello_account = TrelloAccount.new(params[:trello_account]) do |tu|
        tu.token  = request_token.token
        tu.secret = request_token.secret
      end
      Rails.logger.info @trello_account.inspect
      redirect_to request_token.authorize_url(:oauth_callback => callback_trello_accounts_url)
    end

    Rails.logger.info TrelloAccount.request(params[:trello_account][:name]).inspect
  end

  def callback
    Rails.logger.info "callback received..................."
    Rails.logger.info params.inspect

  end

    # get "/request-token" do
    #   if oauth_verified?
    #     redirect to("/")
    #   else
    #     redirect request_token.authorize_url(:oauth_callback => url('/'))
    #   end
    # end

    # get "/callback" do
    #   # handle no params[:oauth_verifier]
    #   # handle no access token
    #   oauth_verify! params[:oauth_verifier]
    #   redirect to("/"), params
    # end

  private

  def access_token
    @access_token ||= begin
      return nil unless token = request.cookies["access_token"]
      Marshal.load(redis.get(token))
    end
  end

  def request_token
    if session[:request_token] && session[:request_token_secret]
      ::OAuth::RequestToken.new(consumer, session[:request_token], session[:request_token_secret])
    else
      rtoken = consumer.get_request_token
      session[:request_token] = rtoken.token
      session[:request_token_secret] = rtoken.secret
      rtoken
    end
  end

  def consumer
    ::OAuth::Consumer.new(ENV['TRELLO_USER_KEY'], settings.consumer_secret,
                             :site => settings.site,
                             :request_token_path => settings.request_token_path,
                             :authorize_path => settings.authorize_path,
                             :access_token_path => settings.access_token_path,
                             :http_method => :get)
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
