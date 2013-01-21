module DateTimeHelper

  def now
    Clock.time
  end

  def today
    Clock.date
  end

end
