require 'spec_helper'

feature "Projects" do
  let(:user) { create(:user) }

  before do
    login_as user
  end

  def create_project(attrs = {})
    form = ProjectForm.new(attributes_for(:project))
    attrs.each { |name, val| form.send("#{name}=", val) }
    form.save
    form.project
  end

  scenario "Connect trello account", vcr: { record: :new_episodes } do
    trello_account = build(:trello_account)

    visit start_project_path
    fill_in "Name", with: trello_account.name
    fill_in "Token", with: trello_account.token
    click_button "Enter"

    page.should have_content("Import a Project")
  end

  scenario "Import a project", vcr: { record: :new_episodes } do
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

  scenario "Configure project settings"  do
    project = create(:project)
    project.add_moderator(user)

    visit project_path(project)
    click_link "Configure"

    fill_in "Name", with: "New Project Name"
    # select "Eastern Time", from: "Time Zone"
    # ActiveSupport::TimeZone.us_zones

    click_button "Save"

    page.should have_content("New Project Name")
    page.should have_content("Eastern Time")
  end
end
