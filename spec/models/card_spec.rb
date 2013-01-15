require 'spec_helper'

describe Card do
  include RedisKeys

  it { should belong_to(:project) }
  it { should belong_to(:list) }
  it { should belong_to(:trello_account) }

  describe "#record_interval" do
    let(:card) { create(:card) }
    let(:list) { create(:list) }

    let(:time_zone) { ActiveSupport::TimeZone['Central Time (US & Canada)'] }
    let(:midday) { time_zone.parse("Jan 11, 2013 12 PM") }
    let(:now) { Clock.zone_time(time_zone) }
    let(:today) { now.to_date }
    let(:now_tomorrow) { Clock.zone_time(time_zone, 1.day.from_now) }
    let(:tomorrow) { now_tomorrow.to_date }

    before do
      Clock.stub!(:zone_time).and_return(midday)

      list.cards << card
    end

    it "stores list id for interval" do
      card.record_interval(now)
      card.interval[date_key(today, :list_id)].to_i.should eq(list.id)
    end

    it "adds list id to list history" do
      card.record_interval(now)
      card.list_history.members.map(&:to_i).should eq([list.id])

      list_2 = create(:list)
      list_2.cards << card

      card.record_interval(now_tomorrow)
      card.list_history.members.map(&:to_i).sort.should eq([list.id, list_2.id].sort)
    end

    context "end of day" do
      let(:end_of_day) { time_zone.parse("Jan 11, 2013 11 PM") }

      before do
        Clock.stub!(:zone_time).and_return(end_of_day)
      end

      it "increments intervals spent in list" do
        card.record_interval(now)
        card.interval[redis_key(:list_total, list.id)].to_i.should eq(1)
      end
    end
  end
end
