module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def encode_credentials(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end
end
