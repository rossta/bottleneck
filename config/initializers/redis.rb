require 'redis'
require 'redis/objects'

url = ENV['REDISTOGO_URL']
uri = URI.parse(url)
Redis.current = Redis.new(host: uri.host, port: uri.port, password: uri.password)

Resque.redis = Redis.current
