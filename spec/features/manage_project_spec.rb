require 'spec_helper'

feature "Manage project" do
  let(:user) { create(:user) }

  before do
    login_as user
  end

  scenario "Connect trello account", vcr: { record: :new_episodes, re_record_interval: 7.days } do
    trello_account = build(:trello_account)

    visit start_project_path
    fill_in "Name", with: trello_account.name
    fill_in "Token", with: trello_account.token
    click_button "Enter"

    page.should have_content("Import a Project")
  end

  scenario "Import a project", vcr: { record: :new_episodes, re_record_interval: 7.days } do
    trello_account = create(:trello_account)
    board = trello_account.trello_boards.first
    board.name.should eq("Bottleneck")

    visit new_project_path(trello_account_id: trello_account.id)

    within "[class*='trello_board'][data-id='#{board.id}']" do
      click_button "Import"
    end

    page.should have_content("Your project was successfully imported")
    page.should have_content("Bottleneck")
    page.should have_content("Settings")
  end

  context "sub pages" do
    let(:project) { create(:project) }

    before do
      project.add_moderator(user)
      project.lists << create(:list)
    end

    scenario "Configure project settings"  do
      visit project_path(project)
      click_link "Settings"

      within(".edit_project") do
        fill_in "Name", with: "New Project Name"
        select "(GMT-06:00) Central Time (US & Canada)", from: "Time zone"
        click_button "Save"
      end

      click_link "Settings"

      page.should have_content("New Project Name")
      page.should have_content("Central Time")
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
end
