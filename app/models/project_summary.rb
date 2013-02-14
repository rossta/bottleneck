class ProjectSummary
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_accessor :project

  include Virtus

  attribute :date, Date, default: :today_in_project

  delegate :time_zone, to: :project

  def initialize(project, attributes = {})
    @project = project
    super(attributes)
  end

  def lead_time_from_date
    date - lead_time.days
  end

  def range
    Range.new(date - 14.days, date)
  end

  def name; "Summary"; end
  def project_id; project.id; end

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
    project.average_lead_time(range)
  end

  def average_wip
    project.average_wip_count(range)
  end

  def average_arrival_rate
    project.average_arrival_rate(range)
  end

  def today_in_project
    Clock.zone_date(time_zone)
  end
end
