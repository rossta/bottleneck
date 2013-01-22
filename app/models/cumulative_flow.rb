class CumulativeFlow
  include Virtus

  attribute :start_time
  attribute :end_time

  attr_accessor :project

  def title
    "Cumulative Flow: #{days_trailing}"
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

  def to_json
    project.lists.reverse_order.map { |list| list_interval_json(list, start_time, end_time) }.to_json
  end

  def list_interval_json(list, start_time, end_time)
    {
      :name => list.name,
      :data => ListInterval.new(list, start_time, end_time).data,
      :position => list.position
    }
  end

end
