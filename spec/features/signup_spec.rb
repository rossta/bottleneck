require 'spec_helper'

describe "Sign up" do

  it "directs to new project after sign up" do
    name = FactoryGirl.generate(:name)
    email = FactoryGirl.generate(:email)
    visit root_path
    page.should have_content("Measure smarter")
    click_link "Get Started"
    complete_sign_up_form_with name, email
    page.should have_content("You have signed up successfully")
    page.should have_content("Connect with Trello")
  end
end
