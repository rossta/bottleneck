namespace :bootstrap do

  desc "Project interval"
  task :project_interval => :environment do
    require "#{Rails.root}/spec/support/bootstrap"
    Bootstrap.project_for User.find_by_name("rossta")
  end
end

task :bootstrap => ['bootstrap:project_interval']
