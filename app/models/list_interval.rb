class ListInterval
  DateCount = Struct.new(:date, :count) do
    def x; date.to_time.to_i; end
    def y; (count || 0).to_i; end
    def data; { x: x, y: y }; end
  end

  attr_reader :list, :start_date, :end_date

  delegate :name, :position, to: :list

  def initialize(list, start_date, end_date)
    @list, @start_date, @end_date = list, start_date, end_date
  end

  def data
    date_counts.map(&:data)
  end

  def dates
    @dates ||= Range.new(start_date, end_date)
  end

  def counts
    @counts ||= list.interval_counts(dates)
  end

  def date_counts
    dates.to_a.zip(counts).map { |tuple| DateCount.new(tuple[0], tuple[1]) }
  end

  def attributes
    {
      name: list.name,
      data: data,
      position: list.position
    }
  end

end
