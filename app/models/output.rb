class Output
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_accessor :project

  include Virtus

  attribute :date_range, DateRange, default: lambda { |flow, attr| DateRange.new }
  attribute :collapsed, Boolean, default: false

  delegate :interval_in_days, :start_date, :end_date, :dates, to: :date_range

  attr_accessor :project

  def initialize(project, attrs = {})
    @project = project
    super attrs
  end

  # Delegates missing instance methods to the source object.
  def method_missing(method, *args, &block)
    return super unless project.respond_to?(method)

    self.class.delegate method, to: :project
    project.send(method, *args, &block)
  end

  def title
    "Output: #{days_trailing}"
  end
  alias_method :name, :title

  def project_id; project.id; end

  def days_trailing
    "#{interval_in_days} days trailing"
  end

  def series
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
    dates.zip(counts).map { |tuple| DateCount.new(tuple[0], tuple[1]).data }
  end

  def wip_data
    count_data dates.map { |date| project.wip_count(date) }
  end

  def lead_time_data
    count_data dates.map { |date| project.lead_time(date) }
  end

end
