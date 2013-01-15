module RedisKeys

  def redis
    Redis.current
  end

  def redis_key(*segments)
    segments.join('/')
  end

  def date_key(date, *segments)
    redis_key(date.to_s(:number), *segments)
  end

  def date_keys(date_range, *segments)
    date_range.to_a.map { |date| date_key(date, *segments) }
  end

end
