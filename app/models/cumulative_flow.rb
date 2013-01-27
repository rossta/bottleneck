class CumulativeFlow
  include Virtus

  attribute :start_time
  attribute :end_time
  attribute :collapsed, Boolean, default: false

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

  def collapsed?; collapsed; end

  def to_json
    if collapsed
      [
        ListVectorInterval.new(lists.backlog, start_time, end_time).to_json,
        ListVectorInterval.new(lists.wip, start_time, end_time).to_json,
        ListVectorInterval.new(lists.done, start_time, end_time).to_json,
      ].to_json
    else
      lists.flow.reverse_order.map { |list|
        ListInterval.new(list, start_time, end_time).to_json
      }.to_json
    end
  end

  def lists
    project.lists
  end

end
