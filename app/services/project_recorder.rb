class ProjectRecorder
  @queue = :account

  def self.record_interval
    Project.where('trello_account_id IS NOT NULL').find_each do |project|
      puts "Fetching project #{project.id} and recording interval"
      Time.use_zone(project.time_zone) do
        record_project project
      end
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
