module RedisKeys

  def redis
    Redis.current
  end

  def redis_key(*segments)
    segments.join('/')
  end

  def interval_key(date, *segments)
    redis_key(date_interval(date), *segments)
  end

  def interval_keys(date_range, *segments)
    dates.to_a.map { |date| interval_key(date, *segments) }
  end

  def date_interval(date = Date.today)
    date.to_s(:number)
  end
end
