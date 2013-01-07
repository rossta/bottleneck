namespace :interval do

  desc "Record intervals for existing projects"
  task :record => :environment do
    ProjectRecorder.record_interval
  end
end
