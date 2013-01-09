require 'spec_helper'

describe TrelloAccount do

  describe "#trello_member", vcr: { record: :new_episodes } do
    let(:trello_account) { build(:trello_account) }

    it "fetches member data for given trello account name" do
      member = trello_account.trello_member
      member.username.should eq(trello_account.name)
    end
  end

  describe "#trello_boards", vcr: { record: :new_episodes } do
    let(:trello_account) { build(:trello_account) }

    it "fetches trello board data" do
      boards = trello_account.trello_boards
      names = boards.map(&:name)
      names.should include('Bottleneck')
      names.should include('Welcome Board')
    end
  end
end
