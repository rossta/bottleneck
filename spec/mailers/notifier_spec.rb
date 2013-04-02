require 'spec_helper'

describe "Notifier" do
  it "delivers project_preview_email" do
    user = stub_model(User, email: 'rossta@example.com')
    project = stub_model(Project, owner: user)
    Notifier.project_preview_email(project).deliver
  end
end
