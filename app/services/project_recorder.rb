class ProjectRecorder
  @queue = :account

  def self.record_interval
    Project.find_each do |project|
      record_project project
    end
  end

  def self.perform(project_id)
    puts "Fetching project #{project_id} and recording interval"
    record_project Project.find(project_id)
  end

  def self.record_project(project)
    project.fetch
    project.record_interval
  end
end
