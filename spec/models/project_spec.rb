require 'spec_helper'

describe Project do
  let(:project) { Project.new }
  let(:default_project) { build(:project) }
  let(:trello_account) { build(:trello_account) }

  describe "#trello_board", vcr: { record: :new_episodes } do
    before do
      project.uid = default_project.uid
      project.trello_account = trello_account
    end

    it "retrieves trello board via trello account api" do
      trello_board = project.trello_board
      trello_board.name.should eq('Sternoapp')
    end
  end
end
