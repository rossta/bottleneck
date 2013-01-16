require 'spec_helper'

describe List do
  include RedisKeys

  describe "#name"
  describe "#position"
  describe "#role"  # maybe state?

  describe "#record_interval" do
    let(:list) { create(:list) }

    let(:time_zone) { ActiveSupport::TimeZone['Central Time (US & Canada)'] }
    let(:midday) { time_zone.parse("Jan 11, 2013 12 PM") }
    let(:now) { Clock.zone_time(time_zone) }
    let(:today) { now.to_date }
    let(:now_tomorrow) { Clock.zone_time(time_zone, 1.day.from_now) }
    let(:tomorrow) { now_tomorrow.to_date }

    before do
      Clock.stub!(:zone_time).and_return(midday)
      list.cards << build(:card) << build(:card) << build(:card)
      list.cards.each do |card|
        card.stub!(:record_interval)
      end
    end

    it "stores card total for interval" do
      list.record_interval(now)
      list.interval[date_key(today, :card_count)].to_i.should eq(3)

      list.cards = [build(:card)]
      list.record_interval(now_tomorrow)
      list.interval[date_key(tomorrow, :card_count)].to_i.should eq(1)
    end

    it "stores card ids for interval" do
      list.record_interval(now)
      list.interval[date_key(today, :card_ids)].should eq(list.card_ids)
    end

    it "stores cumulative total for interval" do
      list.record_interval(now)
      list.interval[date_key(today, :cumulative_total)].to_i.should eq(3)

      list.cards = [build(:card)]
      list.record_interval(now + 1.day)
      list.interval[date_key(today + 1, :cumulative_total)].to_i.should eq(4)

      list.cards = []
      list.record_interval(now + 2.days)
      list.interval[date_key(today + 2, :cumulative_total)].to_i.should eq(4)
    end

    it "stores card ids in card history" do
      list.record_interval(now)
      list.card_history.members.map(&:to_i).sort.should eq(list.card_ids.sort)
    end

    it "records interval for each card" do
      time = Clock.time
      list.cards.each do |card|
        card.should_receive(:record_interval).with(time)
      end
      list.record_interval(time)
    end

    it "records empty card list" do
      list.cards = []
      list.record_interval(now)
      list.interval[date_key(today, :card_count)].to_i.should eq(0)
      list.interval[date_key(today, :cumulative_total)].to_i.should eq(0)
      list.card_history.size.should eq(0)
    end

    context "end of day" do
      let(:end_of_day) { time_zone.parse("Jan 11, 2013 11 PM") }

      before do
        Clock.stub!(:zone_time).and_return(end_of_day)
      end

      it "increments total intervals" do
        list.record_interval(now)
        list.interval[:total].to_i.should eq(1)
      end

      it "increments total cards counted" do
        list.record_interval(now)
        list.interval[:card_count].to_i.should eq(3)
      end
    end
  end
end
