namespace :notify do

  desc "Notify selected projects"
  task :preview => :environment do
    selected_names = %w[ Bottleneck ]
    Project.where(name: selected_names).each do |name|
      Notifier.project_preview_email(project).deliver
    end
  end

end
