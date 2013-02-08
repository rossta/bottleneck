require 'spec_helper'

describe "Cumulative Flows Api", type: :api do
  let(:user) { create(:user) }
  let(:time) { Time.now }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:cumulative_flow) { CumulativeFlow.new(project) }

  before do
    Clock.stub!(:time).and_return(time)
    project.add_moderator(user)
  end

  describe "/cumulative_flows/:project_id" do
    it "returns cumulative flow by project id" do
      authenticated_get "/api/cumulative_flows/#{project.id}", user.authentication_token

      flow_json = cumulative_flow.active_model_serializer.new(cumulative_flow, root: 'cumulative_flow').to_json
      last_response.status.should eq(200)
      puts last_response.body
      last_response.body.should eq(flow_json)

      flow = JSON.parse(last_response.body)["cumulative_flow"]
      flow["title"].should eq("Cumulative Flow: 14 days trailing")
      flow["collapsed"].should eq(false)
    end

    it "returns not found" do
      authenticated_get "/api/cumulative_flows/not_found", user.authentication_token

      last_response.status.should eq(404)
    end
  end

end
