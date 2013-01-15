namespace :datafix do

  desc "Add owner as moderator of projects 1.10.2013"
  task :add_owner_as_moderator_of_projects => :environment do
    Project.find_each do |project|
      owner = project.owner

      puts "#{project.name}:#{project.id}..."
      if project.has_moderator?(owner)
        puts "No action: #{owner.name}:#{owner.id} is already a moderator"
      else
        puts "Adding #{owner.name}:#{owner.id} as a moderator"
        project.add_moderator(owner)
      end
    end
  end

  desc "Add project id to cards 1.14.2012"
  task :add_project_id_to_cards => :environment do
    Project.find_each do |project|
      project.cards.each do |card|
        card.project = project
        card.save!
      end
    end
  end
end
