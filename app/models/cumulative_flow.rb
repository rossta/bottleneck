class CumulativeFlow
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_accessor :project

  include Virtus

  attribute :start_time, ActiveSupport::TimeWithZone, default: :default_start_time
  attribute :end_time, ActiveSupport::TimeWithZone, default: :default_end_time
  attribute :collapsed, Boolean, default: false

  def initialize(project, attributes = {})
    @project = project
    super(attributes)
  end

  # Delegates missing instance methods to the source object.
  def method_missing(method, *args, &block)
    return super unless project.respond_to?(method)

    self.class.delegate method, to: :project
    project.send(method, *args, &block)
  end

  def name
    "Cumulative Flow"
  end

  def title
    "#{name}: #{interval_in_days} days trailing"
  end

  def interval_in_days
    ((end_time - start_time).round / 1.day)
  end

  def start_date; start_time.to_date; end
  def end_date; end_time.to_date; end

  def dates
    @dates ||= Range.new(start_date, end_date)
  end

  def series
    if collapsed
      [
        ListVectorInterval.new(lists.backlog, start_date, end_date),
        ListVectorInterval.new(lists.wip, start_date, end_date),
        ListVectorInterval.new(lists.done, start_date, end_date)
      ]
    else
      lists.flow.reverse_order.map { |list|
        ListInterval.new(list, start_date, end_date)
      }
    end
  end

  def series_json
    series.map(&:to_json).to_json
  end

  def default_start_time
    Clock.zone_time(time_zone, default_time - 14.days)
  end

  def default_end_time
    Clock.zone_time(time_zone, default_time)
  end

  def default_time
    @default_time ||= Clock.time
  end
end
