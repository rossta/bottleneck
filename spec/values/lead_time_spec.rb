require 'spec_helper'

describe LeadTime do
  let(:project) { stub_model(Project) }
  let(:today) { Date.today }
  let(:lead_time) { LeadTime.new(project, today) }

  describe "days" do
    let(:capacity_counts) {
      {
        today       => 10,
        (today - 1) => 9,
        (today - 2) => 8,
        (today - 3) => 6
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
      project.stub(created_at: today - 1)
      lead_time.days.should eq(2)
    end
  end
end
