require 'spec_helper'

describe "Project Summaries Api" do
  let(:user) { create(:user) }
  let(:time) { Time.now }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:today) { Clock.zone_date(project.time_zone) }
  let(:project_summary) { ProjectSummary.new(project, date: today) }

  before do
    Clock.stub!(:time).and_return(time)
    project.add_moderator(user)
  end

  describe "/projects/:project_id/summary" do
    it "returns project summary by project id" do
      authenticated_get "/api/projects/#{project.id}/summary", user.authentication_token

      expected_json = project_summary.active_model_serializer.new(project_summary, root: 'project_summary').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(expected_json)

      summary_json = JSON.parse(last_response.body)["project_summary"]
      summary_json["name"].should =~ /Summary/
      summary_json["time_zone"].should == project.time_zone
      summary_json["current_wip"].should eq(project_summary.current_wip)
    end

    it "returns unauthorized" do
      authenticated_get "/api/projects/#{project.id}/summary", "bad-token"

      last_response.status.should eq(406)
    end
  end

end
