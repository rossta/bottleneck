class ProjectRecorder
  @queue = :account

  def self.record_interval
    Project.select("id").find_each do |project|
      Resque.enqueue(self, project.id)
    end
  end

  def self.perform(project_id)
    puts "Fetching project #{project_id} and recording interval"
    project = Project.find(project_id)
    project.fetch
    project.record_interval
  end
end
