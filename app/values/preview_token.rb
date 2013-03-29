class PreviewToken
  include Redis::Objects

  value :token_value

  def initialize(object)
    @object = object
  end

  def id
    "#{@object.class.name.underscore}_#{@object.id}"
  end

  def token
    token_value.value || generate_token_value
  end

  def generate_token_value
    token_value.value = SecureRandom.hex(8)
  end

  def to_s
    token
  end

  def ==(given_token)
    case given_token
    when String
      token == given_token
    when PreviewToken
      token == given_token.token
    else
      false
    end
  end
end
