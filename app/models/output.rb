class Output
  DateCount = Struct.new(:date, :count) do
    def x; date.to_time.to_i; end
    def y; (count || 0).to_i; end
    def data; { x: x, y: y }; end
  end

  include Virtus

  attribute :start_time
  attribute :end_time

  attr_accessor :project

  def title
    "Output: #{days_trailing}"
  end

  def interval_in_days
    ((end_time - start_time) / 1.day).to_i
  end

  def days_trailing
    "#{interval_in_days} days trailing"
  end

  def dates
    @dates ||= Range.new(start_time.to_date, end_time.to_date)
  end

  def data
    [
      {
        :name => 'Total WIP (cards)',
        :data => wip_data,
        :position => 1
      },
      {
        :name => 'Lead Time (days)',
        :data => lead_time_data,
        :position => 2
      }
    ]
  end

  def count_data(counts)
    dates.to_a.zip(counts).map { |tuple| DateCount.new(tuple[0], tuple[1]).data }
  end

  def wip_data
    count_data dates.to_a.map { |date| project.wip_count(date) }
  end

  def lead_time_data
    count_data dates.to_a.map { |date| project.lead_time(date) }
  end

  def to_json
    data.to_json
  end

end
