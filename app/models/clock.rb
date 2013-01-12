class Clock
  class << self
    def time
      Time.zone.now
    end

    def zone_time(time_zone)
      Time.now.in_time_zone(time_zone)
    end

    def date
      time.to_date
    end
  end
end
