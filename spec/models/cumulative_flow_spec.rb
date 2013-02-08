require 'spec_helper'

describe CumulativeFlow do
  def time_zone; ActiveSupport::TimeZone['Central Time (US & Canada)']; end

  def mock_project(attributes = {})
    mock("Project", {
      title: "Scarecrow",
      lists_flow: [mock_list],
      time_zone: time_zone })
  end

  def mock_list(attributes = {})
    mock("List",
      name: "List name",
      position: 1,
      interval_counts: [3, 4])
  end

  let(:project) { mock_project }
  let(:now) { Clock.zone_time(time_zone) }
  let(:cumulative_flow) {
    CumulativeFlow.new(project,
      start_time: (now - 1.day),
      end_time: now)
  }

  it { cumulative_flow.title.should =~ /Cumulative Flow/ }

  describe "series" do
    it "returns intervals for project lists" do
      today = now.to_date
      yesterday = today - 1
      cumulative_flow.series.should == [
        {
          name: "List name",
          data: [{ x: yesterday.to_time.to_i, y: 3 }, { x: today.to_time.to_i, y: 4 }],
          position: 1
        }
      ]
    end
  end
end
