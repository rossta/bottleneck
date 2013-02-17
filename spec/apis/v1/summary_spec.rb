require 'spec_helper'

describe "Project Summaries Api" do
  let(:user) { create(:user) }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:time) { Time.now.in_time_zone(project.time_zone) }
  let(:date_range) { DateRange.new(end_time: time, time_zone: project.time_zone) }
  let(:summary) { Summary.new(project, date_range: date_range) }

  before do
    Clock.stub!(:time).and_return(time)
    project.add_moderator(user)
  end

  describe "/projects/:project_id/summary" do
    it "returns project summary by project id" do
      authenticated_get "/api/projects/#{project.id}/summary", user.authentication_token

      expected_json = summary.active_model_serializer.new(summary, root: 'summary').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(expected_json)

      summary_json = JSON.parse(last_response.body)["summary"]
      summary_json["name"].should =~ /Summary/
      summary_json["time_zone"].should == project.time_zone
      summary_json["current_wip"].should eq(summary.current_wip)
    end

    it "returns unauthorized" do
      authenticated_get "/api/projects/#{project.id}/summary", "bad-token"

      last_response.status.should eq(406)
    end
  end

end
