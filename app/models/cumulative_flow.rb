class CumulativeFlow
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_accessor :project

  include Virtus

  attribute :date_range, DateRange, default: lambda { |flow, attr| DateRange.new }
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

  delegate :interval_in_days, :start_date, :end_date, :dates, to: :date_range

  def series
   project.flow_lists(collapsed: collapsed?).map { |list|
      ListInterval.new(list, dates).attributes
    }
  end

  def series_json
    series.to_json
  end
end
