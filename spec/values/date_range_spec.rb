require 'spec_helper'

describe DateRange do
  let(:time) { Time.zone.now }
  let(:end_time) { time }
  let(:start_time) { time - 14.days }
  let(:date_range) { DateRange.new }

  before do
    Clock.stub!(:time).and_return(time)
  end

  it { date_range.start_time.should eq(start_time) }

  it { date_range.end_time.should eq(end_time) }

  it { date_range.time_zone.should eq(end_time.time_zone) }

  it { date_range.start_date.should eq(start_time.to_date) }

  it { date_range.end_date.should eq(end_time.to_date) }

  it { date_range.omit_weekends?.should be_false }

  it { date_range.dates.should eq(Range.new(start_time.to_date, end_time.to_date).to_a) }

  it { date_range.interval_in_days.should eq(14) }

  describe "calculate_average" do
    it "calculates average over range" do
      value = 0
      object = Object.new
      object.stub(:calc) do |date|
        value += 1
      end
      date_range.calculate_average do |date|
        object.calc(date)
      end.should eq((1..date_range.length).inject(&:+)/14)
    end
  end
end
