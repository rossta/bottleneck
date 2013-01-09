class Clock
  class << self
    def time
      Time.zone.now
    end

    def date
      time.to_date
    end
  end
end
