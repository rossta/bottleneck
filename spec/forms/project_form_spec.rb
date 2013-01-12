require 'spec_helper'

describe ProjectForm do
  let(:user) { stub_model(User) }
  let(:trello_account) { stub_model(TrelloAccount) }
  subject { ProjectForm.new }

  describe "#initialize" do
    it "accepts expected attributes" do
      form = ProjectForm.new(uid: "12345", name: "New Project")
      form.uid.should eq("12345")
      form.name.should eq("New Project")
    end

    it "accepts owner and trello_account objects via block" do
      form = ProjectForm.new do |p|
        p.owner = user
        p.trello_account = trello_account
      end
      form.owner.should eq(user)
      form.trello_account.should eq(trello_account)
    end
  end

  describe "#save" do
    let(:project) { stub_model(Project) }

    let(:form) { ProjectForm.new(attributes) }

    before do
      project.stub!(:save).and_return(true)
      project.stub!(:fetch).and_return(true)
      user.stub!(:add_role)

      form.project = project
      form.owner = user
      form.trello_account = trello_account
    end

    context "valid" do
      let(:attributes) { {
        uid: "1234567890",
        name: "Bottleneck",
        time_zone: "Indiana (East)"
      } }

      it "saves and fetches project" do
        project.should_receive(:save)
        project.should_receive(:fetch)
        form.save
      end

      it "adds moderator role to owner" do
        user.should_receive(:add_role).with(:moderator, project)
        form.save
      end
    end

    context "not valid" do
      let(:attributes) { { } }

      it "does not save or fetch project" do
        project.should_not_receive(:save)
        project.should_not_receive(:fetch)
        form.save
      end

      it "does not add moderator role to owner" do
        user.should_not_receive(:add_role).with(:moderator, project)
        form.save
      end
    end
  end

  describe "#valid?" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:owner) }
    it { should validate_presence_of(:trello_account) }
  end
end
