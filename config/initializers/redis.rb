require 'redis'
require 'redis/objects'
url = ENV['REDISTOGO_URL']
raise "REDISTOGO_URL not defined!!!" unless url
uri = URI.parse(url)
Redis.current = Redis.new(host: uri.host, port: uri.port, password: uri.password)
