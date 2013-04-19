class DateRange
  include Virtus

  attribute :start_time, ActiveSupport::TimeWithZone, default: :default_start_time
  attribute :end_time, ActiveSupport::TimeWithZone, default: :default_end_time
  attribute :omit_weekends, Boolean, default: false

  delegate :first, :last, :begin, :cover?, :each, :end, :include?, :max, :min,
    :member?, to: :range

  delegate :length, to: :dates

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
  alias_method :to_a, :dates

  def default_start_time
    end_time - 14.days
  end

  def default_end_time
    Clock.time
  end

  def default_time
    @default_time ||= Clock.time
  end

  def time_zone
    end_time.time_zone
  end

  def calculate_average(&block)
    ((dates.map { |date| block.call(date) }.inject(&:+)) / dates.length).round(2)
  end

  private

  def range
    @range ||= Range.new(start_date, end_date)
  end

  def all_dates
    @all_dates ||= range.to_a
  end

  def weekday_dates
    all_dates.select { |d| (1..5).include?(d.wday) }
  end

end
