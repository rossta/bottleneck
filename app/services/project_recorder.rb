class ProjectRecorder
  @queue = :account

  def self.record_interval
    Project.find_each(&:record_interval)
    # Project.select("id").find_each do |project|
    #   Resque.enqueue(self, project.id)
    # end
  end

  def self.perform(project_id)
    project = Project.find(project_id)
    project.record_interval
  end
end
