require 'spec_helper'

describe "Projects Api" do
  let(:user) { create(:user) }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:access_denied_project) { create(:project, name: "Access Denied") }

  before do
    project.add_moderator(user)
    access_denied_project
  end

  describe "projects", type: :api do
    it "returns current_user projects" do
      get "/api/projects", nil, {
        'Accept' => 'application/vnd.bottleneck-v1+json',
        'HTTP_AUTHORIZATION' => encode_credentials(user.authentication_token)
      }

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

end
