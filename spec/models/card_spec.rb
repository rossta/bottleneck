require 'spec_helper'

describe Card do
  include RedisKeys

  let(:card) { Card.new }

  it { should belong_to(:project) }
  it { should belong_to(:list) }
  it { should belong_to(:trello_account) }

  context "trello api", vcr: { record: :new_episodes }  do
    before do
      card.uid = generate(:card_uid)
      card.trello_account = build(:trello_account)
    end

    describe "#trello_card" do
      it "exists with valid uid and trello_token" do
        card.trello_card.should be_present
      end

      it "is nil without uid and trello_account" do
        card.uid = nil
        card.trello_account = nil
        card.trello_card.should be_nil
      end
    end

    describe "#labels" do
      it "is populated from trello card" do
        card.fetch
        card.labels.should be_empty
      end

      it "acts as taggable via trello labels" do
        card.trello_labels = [mock("Trello::Label", name: "Bug", color: "red")]
        card.save
        card.reload
        card.labels
        card.label_list.should eq(["Bug"])
      end

      it "is tagged with label" do
        card.label_list = "Bug"
        card.save

        Card.tagged_with(["Bug"]).should include(card)
        Card.tagged_with(["Bug"], on: :labels).should include(card)
        Card.tagged_with(["Bug"], on: :tags).should be_empty
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

    it "returns trello card name with label list" do
      card.name = "Card on trello"
      card.label_list = "Bug, Chore"
      card.save
      card.reload.display_name.should eq("Card on trello (Chore, Bug)")
    end

    it "returns trello card name with trello labels converted to label list" do
      card.name = "Card on trello"
      card.trello_labels = [mock("Trello::Label", name: "Bug", color: "red")]
      card.save
      card.reload.display_name.should eq("Card on trello (Bug)")
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
