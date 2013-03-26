require 'spec_helper'

describe "Cumulative Flows Api" do
  let(:user) { create(:user) }
  let(:time) { Clock.zone_time(project.time_zone) }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:date_range) { DateRange.new(end_time: time, time_zone: project.time_zone) }
  let(:cumulative_flow) { CumulativeFlow.new(project) }

  before do
    project.add_moderator(user)
  end

  describe "/cumulative_flows/:project_id" do
    it "returns cumulative flow by project id" do
      authenticated_get "/api/cumulative_flows/#{project.id}"

      expected_json = cumulative_flow.active_model_serializer.new(cumulative_flow, root: 'cumulative_flow').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(expected_json)

      flow_json = JSON.parse(last_response.body)["cumulative_flow"]
      flow_json["id"].should eq(cumulative_flow.id)
      flow_json["name"].should =~ /Cumulative Flow/
      flow_json["collapsed"].should eq(false)
    end

    it "returns not found" do
      authenticated_get "/api/cumulative_flows/not_found"

      last_response.status.should eq(404)
    end
  end

end
