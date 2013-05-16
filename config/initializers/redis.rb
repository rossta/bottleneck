require 'redis'
require 'redis/objects'

klass = Bottleneck::Application.config.redis_class
url   = ENV['REDISTOGO_URL'] || 'redis://localhost:6421'
uri   = URI.parse(url)
redis = klass.new(host: uri.host, port: uri.port, password: uri.password)

Redis.current = redis
Resque.redis = redis
