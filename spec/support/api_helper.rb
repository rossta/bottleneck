module ApiHelper
  include Rack::Test::Methods

  def app
    Rails.application
  end

  def encode_credentials(token)
    ActionController::HttpAuthentication::Token.encode_credentials(token)
  end

  def authenticated_env(token)
    {
      'Accept' => 'application/vnd.bottleneck-v1+json',
      'HTTP_AUTHORIZATION' => encode_credentials(token)
    }
  end

  def authenticated_get(path, token, params = {}, rack_env = {})
    get path, params, authenticated_env(token).merge(rack_env)
  end

  def authenticated_delete(path, token, params = {}, rack_env = {})
    delete path, params, authenticated_env(token).merge(rack_env)
  end
end
