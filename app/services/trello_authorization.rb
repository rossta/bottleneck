class TrelloAuthorization
  include Trello
  include Trello::Authorization

  def self.authorize!
    Trello::Authorization.const_set :AuthPolicy, OAuthPolicy
    OAuthPolicy.consumer_credential = OAuthCredential.new(ENV['TRELLO_USER_KEY'], ENV['TRELLO_USER_SECRET'])
  end

  def self.create_trello_account(return_url, &block)
    OAuthPolicy.return_url = return_url
    OAuthPolicy.callback = Proc.new do |request_token|
      OAuthPolicy.token = OAuthCredential.new request_token.token, request_token.secret
      block.call request_token
    end
  end

  def self.session(token, secret = nil)
    result = nil
    current_token = OAuthPolicy.token
    OAuthPolicy.token = OAuthCredential.new(token, secret)
    result = yield if block_given?
    OAuthPolicy.token = current_token
    result
  end

end
