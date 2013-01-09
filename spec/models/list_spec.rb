require 'spec_helper'

describe List do
  include RedisKeys

  describe "#record_interval" do
    let(:list) { create(:list) }

    before do
      list.cards << build(:card) << build(:card) << build(:card)
    end

    it "increments total intervals" do
      list.record_interval
      list.interval[:total].to_i.should eq(1)
    end

    it "increments total cards counted" do
      list.record_interval
      list.interval[:card_count].to_i.should eq(3)
    end

    it "stores card total for interval" do
      list.record_interval
      list.interval[interval_key(Clock.date, :card_count)].to_i.should eq(3)
    end

    it "stores card ids for interval" do
      list.record_interval
      list.interval[interval_key(Clock.date, :card_ids)].should eq(list.card_ids)
    end

    it "records interval for each card" do
      time = Clock.time
      list.cards.each do |card|
        card.should_receive(:record_interval).with(time)
      end
      list.record_interval(time)
    end

  end
end
