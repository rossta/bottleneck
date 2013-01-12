require 'spec_helper'

describe Card do
  include RedisKeys

  describe "#record_interval" do
    let(:card) { create(:card) }
    let(:list) { create(:list) }

    before do
      list.cards << card
    end

    it "stores list id for interval" do
      card.record_interval
      card.interval[interval_key(Clock.date, :list_id)].to_i.should eq(list.id)
    end

    it "increments intervals spent in list" do
      card.record_interval(Clock.time, end_of_day: true)
      card.interval[redis_key(:list_total, list.id)].to_i.should eq(1)
    end
  end
end
