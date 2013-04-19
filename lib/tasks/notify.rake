namespace :notify do

  desc "Notify selected projects"
  task :preview => :environment do
    names = %w[ Challenges/Platform ]
    emails = %w[ ross@challengepost.com ]
    Project.where(name: names).each do |project|
      emails.each do |email|
        Notifier.project_preview_email(project).deliver
      end
    end
  end
end