namespace :bootstrap do

  desc "Project interval"
  task :project_interval => :environment do
    require "#{Rails.root}/db/bootstrap/project_data"
  end
end
