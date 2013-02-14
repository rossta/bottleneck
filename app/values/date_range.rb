class DateRange
  include Virtus

  attribute :start_time, ActiveSupport::TimeWithZone, default: :default_start_time
  attribute :end_time, ActiveSupport::TimeWithZone, default: :default_end_time
  attribute :time_zone, ActiveSupport::TimeZone, default: Time.zone
  attribute :omit_weekends, Boolean, default: false

  def start_date; start_time.to_date; end
  def end_date; end_time.to_date; end

  def interval_in_days
    ((end_time - start_time).round / 1.day)
  end

  def dates
    if omit_weekends?
      weekday_dates
    else
      all_dates
    end
  end

  def default_start_time
    end_time - 14.days
  end

  def default_end_time
    Clock.zone_time(time_zone, default_time)
  end

  def default_time
    @default_time ||= Clock.time
  end

  private

  def all_dates
    @all_dates ||= Range.new(start_date, end_date).to_a
  end

  def weekday_dates
    all_dates.select { |d| (1..5).include?(d.wday) }
  end

end
