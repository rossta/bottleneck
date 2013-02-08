require 'spec_helper'

describe "Projects Api", type: :api do
  let(:user) { create(:user) }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:access_denied_project) { create(:project, name: "Access Denied") }

  before do
    project.add_moderator(user)
    access_denied_project
  end

  describe "/projects" do
    it "returns current_user projects" do
      authenticated_get "/api/projects", user.authentication_token

      projects_json = user.projects.active_model_serializer.new(user.projects, root: 'projects').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(projects_json)

      projects = JSON.parse(last_response.body)["projects"]
      projects.any? do |p|
        p["name"] == "Scarecrow"
      end.should be_true

      projects.any? do |p|
        p["name"] == "Access Denied"
      end.should be_false
    end
  end

  describe "/project/:project_id" do
    it "returns project by id" do
      authenticated_get "/api/projects/#{project.id}", user.authentication_token

      project_json = project.active_model_serializer.new(project, root: 'project').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(project_json)

      project = JSON.parse(last_response.body)["project"]
      project["name"].should eq("Scarecrow")
    end

    it "returns not found" do
      authenticated_get "/api/projects/#{access_denied_project.id}", user.authentication_token

      last_response.status.should eq(404)
    end
  end

end
