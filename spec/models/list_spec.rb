require 'spec_helper'

describe List do
  include RedisKeys

  describe "#name"
  describe "#position"
  describe "#role"  # maybe state?

  describe "#record_interval" do
    let(:list) { create(:list) }
    let(:time_zone) { ActiveSupport::TimeZone['Central Time (US & Canada)'] }
    let(:now) { Clock.zone_time(time_zone) }
    let(:today) { now.to_date }
    let(:now_tomorrow) { Clock.zone_time(time_zone, 1.day.from_now) }
    let(:tomorrow) { now_tomorrow.to_date }

    before do
      list.cards << build(:card) << build(:card) << build(:card)
    end

    it "stores card total for interval" do
      list.record_interval(now)
      list.interval[interval_key(today, :card_count)].to_i.should eq(3)

      list.cards = [build(:card)]
      list.record_interval(now_tomorrow)
      list.interval[interval_key(tomorrow, :card_count)].to_i.should eq(1)
    end

    it "stores card ids for interval" do
      list.record_interval(now)
      list.interval[interval_key(today, :card_ids)].should eq(list.card_ids)
    end

    it "stores cumulative total for interval" do
      list.record_interval(now)
      list.interval[interval_key(today, :cumulative_total)].to_i.should eq(3)

      list.cards = [build(:card)]
      list.record_interval(now_tomorrow)
      list.interval[interval_key(tomorrow, :cumulative_total)].to_i.should eq(4)
    end

    it "stores card ids in card history" do
      list.record_interval(now)
      list.card_history.members.map(&:to_i).sort.should eq(list.card_ids.sort)
    end

    it "records interval for each card" do
      time = Clock.time
      list.cards.each do |card|
        card.should_receive(:record_interval).with(time, {})
      end
      list.record_interval(time)
    end

    context "end of day" do
      it "increments total intervals" do
        list.record_interval(now, end_of_day: true)
        list.interval[:total].to_i.should eq(1)
      end

      it "increments total cards counted" do
        list.record_interval(now, end_of_day: true)
        list.interval[:card_count].to_i.should eq(3)
      end
    end

  end
end
