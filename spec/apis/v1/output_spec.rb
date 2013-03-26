require 'spec_helper'

describe "Project Output Api" do
  let(:user) { create(:user) }
  let(:time) { Time.now }
  let(:project) { create(:project, name: "Scarecrow") }
  let(:today) { Clock.zone_date(project.time_zone) }
  let(:output) { Output.new(project, date: today) }

  before do
    Clock.stub!(:time).and_return(time)
    project.add_moderator(user)
  end

  describe "/projects/:project_id/output" do
    it "returns project output by project id" do
      authenticated_get "/api/projects/#{project.id}/output"

      expected_json = output.active_model_serializer.new(output, root: 'output').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(expected_json)

      output_json = JSON.parse(last_response.body)["output"]
      output_json["name"].should =~ /Output/
      output_json["time_zone"].should == project.time_zone
    end

    it "returns unauthorized" do
      get "/api/projects/#{project.id}/output"

      last_response.status.should eq(401)
    end
  end

end
