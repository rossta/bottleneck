class Clock
  class << self
    def time
      Time.zone.now
    end

    def zone_time(time_zone, time = Clock.time)
      time.in_time_zone(time_zone)
    end

    def zone_date(time_zone, time = Clock.time)
      zone_time(time_zone, time).to_date
    end

    def date
      time.to_date
    end
  end
end
