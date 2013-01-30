module RedisIntervals
  # Extensions for models using redis object hash_key :interval

  def store_interval(key, value)
    interval.store(key, value)
  end

  def incr_interval(*args)
    interval.incr(*args)
  end

  def interval_key?(key)
    interval.has_key?(key)
  end

  def interval_count(key)
    interval[key].to_i
  end

  def interval_date_count(date, *segments)
    interval_count date_key(date, *segments)
  end
end
