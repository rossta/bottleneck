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

  desc "Add Public Trello Development Board to Bottleneck user"
  task :add_public_trello_development_to_bottleneck => :environment do
    user = User.find_by_name!("bottleneck")

    last_project    = user.owned_projects.last
    trello_account  = last_project.trello_account
    trello_board    = trello_account.client.find(:board, "4d5ea62fd76aa1136000000c")

    unless user.owned_projects.find_by_name(trello_board.name)
      form = ProjectForm.new(name: trello_board.name, uid: trello_board.id)
      form.trello_account = trello_account
      form.owner = user
      form.save
    end
  end
end
