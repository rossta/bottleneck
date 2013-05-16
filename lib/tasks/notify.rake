namespace :notify do

  desc "Notify selected projects"
  task :preview => :environment do
    if Date.today.strftime("%A") == 'Friday'
      names = %w[ Challenges/Platform ]
      emails = %w[ tech@challengepost.com ]
      Project.where(name: names).each do |project|
        emails.each do |email|
          Notifier.project_preview_email(project, email).deliver
        end
      end
    end
  end
end
