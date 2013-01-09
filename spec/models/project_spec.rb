require 'spec_helper'

describe Project do
  include RedisKeys

  let(:project) { Project.new }

  describe "#trello_board", vcr: { record: :new_episodes } do
    let(:project) { build(:project) }

    it "retrieves trello board via trello account api" do
      trello_board = project.trello_board
      trello_board.name.should eq('Bottleneck')
    end
  end

  describe "#record_interval" do
    let(:project) { create(:project) }
    let(:list) { build(:list) }

    before do
      list.cards << build(:card) << build(:card) << build(:card)
      project.lists << list
    end

    it "increments total intervals counted" do
      project.record_interval
      project.interval[:total].to_i.should eq(1)
    end

    it "increments total cards counted" do
      project.record_interval
      project.interval[:cards].to_i.should eq(3)
    end

    it "sets card count for date" do
      project.record_interval
      project.interval[interval_key(Clock.date, :card_count)].to_i.should eq(3)
    end

    it "sets list_ids for date" do
      project.record_interval
      project.interval[interval_key(Clock.date, :list_ids)].should eq([list.id])
    end

    it "records intervals for each list" do
      time = Clock.time
      list.should_receive(:record_interval).with(time)
      project.record_interval(time)
    end
  end
end
