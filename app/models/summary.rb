class Summary
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_accessor :project

  include Virtus

  attribute :date_range, DateRange, default: lambda { |flow, attr| DateRange.new }

  delegate :time_zone, to: :project

  def initialize(project, attributes = {})
    @project = project
    super(attributes)
  end

  def lead_time_from_date
    date - lead_time.days
  end

  def name; "Summary"; end
  def project_id; project.id; end

  def date
    date_range.end_date
  end

  def current_wip
    project.wip_count(date)
  end

  def starting_wip
    project.wip_count(lead_time_from_date)
  end

  def lead_time
    project.lead_time(date)
  end

  def arrival_rate
    project.arrival_rate(date)
  end

  def capacity
    project.capacity_count(date)
  end

  def average_lead_time
    project.average_lead_time(date_range)
  end

  def average_wip
    project.average_wip_count(date_range)
  end

  def average_arrival_rate
    project.average_arrival_rate(date_range)
  end
end
