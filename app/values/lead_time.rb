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

  def calculate
    days_ago  = 0
    done      = project.done_count(date)
    capacity  = project.capacity_count(date)

    # back track one day at a time until capacity
    # was less than or equal to currently done
    # "times out" over 100
    while done < capacity
      days_ago += 1
      break if days_ago > 100
      capacity = project.capacity_count(date - days_ago.days)
    end

    days_ago
  end
end
