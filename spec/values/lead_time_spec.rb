require 'spec_helper'

describe LeadTime do
  let(:project) { stub_model(Project) }
  let(:today) { Date.today }
  let(:lead_time) { LeadTime.new(project, today) }

  describe "days" do
    let(:capacity_counts) {
      {
        today               => 10,
        1.day.ago.to_date   => 9,
        2.days.ago.to_date  => 8,
        3.days.ago.to_date  => 6
      }
    }

    before do
      project.stub(created_at: 101.days.ago)
      project.stub!(:done_count).with(today).and_return(7)

      capacity_counts.each do |date, count|
        project.stub(:capacity_count).ordered.with(date).and_return(count)
      end
    end

    it "returns days elapsed between equivalent past capacity current done" do
      lead_time.days.should eq(3)
    end

    it "works as class method" do
      LeadTime.days(project, today).should eq(3)
    end

    it "short circuits on project created_at" do
      project.stub(created_at: 1.day.ago)
      lead_time.days.should eq(2)
    end
  end
end
