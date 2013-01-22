require 'spec_helper'

feature "Manage project" do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  before do
    project.add_moderator(user)
    project.lists << create(:list)
    login_as user
  end

  scenario "View cumulative flow", js: true  do
    visit project_path(project)
    click_link "Flow"

    within "#project_#{project.id}" do
      page.should have_content("Cumulative Flow")
      page.should have_css("#chart")
    end
  end

  scenario "View output", js: true  do
    visit project_path(project)
    click_link "Output"

    within "#project_#{project.id}" do
      page.should have_content("Output")
      page.should have_css("#chart")
    end
  end

  scenario "View breakdown", js: true  do
    visit project_path(project)
    click_link "Breakdown"

    within "#project_#{project.id}" do
      page.should have_content("Breakdown")
    end
  end
end
