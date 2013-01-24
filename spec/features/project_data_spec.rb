require 'spec_helper'

feature "Project Data" do
  let(:user) { create(:user) }
  let(:project) { user.owned_projects.find_by_name("Scarecrow") }

  scenario "Overview" do
    Bootstrap.project_for user
    project.add_moderator(user)
    login_as user

    time_zone = project.time_zone
    visit project_path(project)
    page.should have_content("Cumulative Flow:")
    page.should have_content("days trailing")

    within("[data='total-wip']") do
      page.should have_content("Total WIP")
      page.should have_content("8 cards")
    end
  end
end
