require 'spec_helper'

describe Card do
  include RedisKeys

  let(:card) { Card.new }

  it { should belong_to(:project) }
  it { should belong_to(:list) }
  it { should belong_to(:trello_account) }

  describe "#trello_token" do
    it "delegates to project" do
      card.project = stub_model(Project, trello_token: "12345678")
      card.trello_token.should eq("12345678")
    end

    it "returns nil if no project" do
      card.trello_token.should be_nil
    end
  end

  context "trello api", vcr: { record: :new_episodes }  do
    before do
      card.uid = generate(:card_uid)
      card.trello_token = generate(:trello_token)
    end

    describe "#trello_card" do
      it "exists with valid uid and trello_token" do
        card.trello_card.should be_present
      end

      it "is nil without uid and trello_token" do
        card.uid = nil
        card.trello_token = nil
        card.trello_card.should be_nil
      end
    end

    describe "#labels", vcr: { record: :new_episodes } do
      it "is populated from trello card" do
        card.fetch
        card.labels.should be_empty
      end

      it "persists labels array" do
        card.labels = [{"name" => "Bug", "color" => "red"}]
        card.save

        Card.find(card.id).labels.should eq([{"name" => "Bug", "color" => "red"}])
      end
    end
  end

  describe "#display_name" do
    it "returns unlabeled if no trello name or card" do
      card.display_name.should eq("[Unlabeled]")
    end

    it "returns trello name" do
      card.name = "Card on trello"
      card.display_name.should eq("Card on trello")
    end

    it "returns trello card name if no trello name" do
      card.name = "Card on trello"
      card.labels = [{name: "Bug", color: "red"}]
      card.display_name.should eq("Card on trello (Bug)")
    end
  end

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
