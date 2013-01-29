class ProjectRecorder
  @queue = :account

  def self.record_interval
    puts "Recording project intervals at #{Time.now}"
    Project.trello_based.find_each do |project|
      record_project project
    end
    puts "Done\n"
  end

  def self.perform(project_id)
    record_project Project.find(project_id)
  end

  def self.record_project(project)
    puts "Fetching project #{project.id} and recording interval"
    Time.use_zone(project.time_zone) do
      project.fetch
      project.record_interval
    end
  end
end
