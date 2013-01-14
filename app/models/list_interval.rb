class ListInterval
  DateCount = Struct.new(:date, :count) do
    def x; date.to_time.to_i; end
    def y; (count || 0).to_i; end
  end

  attr_reader :list, :beg_of_period, :end_of_period

  delegate :name, :position, to: :list

  def initialize(list, beg_of_period, end_of_period)
    @list, @beg_of_period, @end_of_period = list, beg_of_period, end_of_period
  end

  def data
    date_counts.map { |dc| { x: dc.x, y: dc.y } }
  end

  def dates
    @dates ||= Range.new(beg_of_period.to_date, end_of_period.to_date)
  end

  def counts
    @counts ||= list.interval_counts(dates)
  end

  def date_counts
    dates.to_a.zip(counts).map { |tuple| DateCount.new(tuple[0], tuple[1]) }
  end
end
