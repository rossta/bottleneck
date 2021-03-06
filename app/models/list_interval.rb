class ListInterval
  attr_reader :list
  attr_accessor :dates

  delegate :name, :position, to: :list

  def initialize(list, dates)
    @list, @dates = list, dates
  end

  def data
    date_counts.map(&:data)
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
