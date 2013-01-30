require 'spec_helper'

describe Project do
  include RedisKeys

  let(:project) { Project.new }

  describe "#trello_board", vcr: { record: :new_episodes } do
    let(:project) { build(:trello_linked_project) }

    it "retrieves trello board via trello account api" do
      trello_board = project.trello_board
      trello_board.name.should eq('Bottleneck')
    end
  end

  describe "#record_interval" do
    let(:project) { create(:project) }
    let(:list) { build(:list) }
    let(:time_zone) { ActiveSupport::TimeZone[project.time_zone] }
    let(:now) { Clock.zone_time(time_zone) }
    let(:today) { now.to_date }

    before do
      list.cards << build(:card, label_list: 'Bug') << build(:card, label_list: 'Story') << build(:card)
      list.stub!(:record_interval)
      LeadTime.stub!(days: 4)
      project.lists << list
    end

    it "sets card count for date" do
      project.record_interval(now)
      project.interval[date_key(today, :card_count)].to_i.should eq(3)
    end

    it "sets list_ids for date" do
      project.record_interval(now)
      project.interval[date_key(today, :list_ids)].should eq([list.id])
    end

    it "stores list_ids for all time in list history" do
      project.record_interval(now)
      project.list_history.members.map(&:to_i).should eq([list.id])
    end

    it "stores card ids in card history" do
      project.record_interval(now)
      project.card_history.members.map(&:to_i).sort.should eq(list.card_ids.sort)
    end

    it "records intervals for each list" do
      time = Clock.time
      list.should_receive(:record_interval).with(time)
      project.record_interval(time)
    end

    it "records backlog count" do
      list.update_attributes(role: List::BACKLOG)
      project.record_interval(now)
      project.backlog_count(today).should eq(3)
      project.wip_count(today).should eq(0)
      project.done_count(today).should eq(0)
    end

    it "records wip count" do
      list.update_attributes(role: List::WIP)
      project.record_interval(now)
      project.wip_count(today).should eq(3)
      project.backlog_count(today).should eq(0)
      project.done_count(today).should eq(0)
    end

    it "records done count" do
      list.interval.store(date_key(today, :cumulative_total), 2)
      list.update_attributes(role: List::DONE)
      project.record_interval(now)
      project.done_count(today).should eq(2)
      project.wip_count(today).should eq(0)
      project.backlog_count(today).should eq(0)
    end

    it "records lead time" do
      LeadTime.should_receive(:days).and_return(4)
      project.record_interval(now)
      project.lead_time(today).should eq(4)
    end

    it "records card label counts" do
      project.record_interval(now)
      project.interval[date_key(today, :card_count, 'Bug')].to_i.should eq(1)
      project.interval[date_key(today, :card_count, 'Story')].to_i.should eq(1)
    end

    it "records lists empty of cards" do
      list.cards = []
      project.record_interval(now)
      project.interval[date_key(today, :card_count)].to_i.should eq(0)
      project.interval[date_key(today, :cumulative_total)].to_i.should eq(0)
      project.card_history.size.should eq(3)
    end

    it "records empty of lists" do
      project.lists = []
      project.record_interval(now)
      project.interval[date_key(today, :card_count)].to_i.should eq(0)
      project.interval[date_key(today, :cumulative_total)].to_i.should eq(0)
      project.list_history.size.should eq(0)
      project.card_history.size.should eq(3)
    end

    it "records lists then empty of lists" do
      project.record_interval(now)
      project.lists = []
      project.record_interval(now)
      project.interval[date_key(today, :card_count)].to_i.should eq(0)
      project.interval[date_key(today, :cumulative_total)].to_i.should eq(0)
      project.list_history.size.should eq(1)
      project.card_history.size.should eq(3)
    end

    context "end of day" do
      let(:end_of_day) { time_zone.parse("Jan 11, 2013 11 PM") }

      before do
        Clock.stub!(:zone_time).and_return(end_of_day)
      end

      it "increments total intervals counted" do
        project.record_interval
        project.interval[:total].to_i.should eq(1)
      end

      it "increments total cards counted" do
        project.record_interval
        project.interval[:cards].to_i.should eq(3)
      end
    end
  end
end
