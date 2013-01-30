class LeadTime
  def self.days(project, date)
    new(project, date).days
  end

  attr_reader :project, :date
  def initialize(project, date)
    @project, @date = project, date
  end

  def days
    calculate
  end

  def done
    @done ||= project.done_count(date)
  end

  def capacity_at(given_date)
    project.capacity_count(given_date)
  end

  def oldest_date
    project.created_at.to_date
  end

  def calculate
    days_ago  = 0
    capacity  = capacity_at(date)

    # back track one day at a time until capacity
    # was less than or equal to currently done
    # "times out" over 100
    while done < capacity
      days_ago += 1
      date_ago = date - days_ago.days
      break if days_ago > 100 || date_ago < oldest_date

      capacity = project.capacity_count(date_ago)
    end

    days_ago
  end
end
