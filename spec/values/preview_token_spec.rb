require 'spec_helper'

describe PreviewToken do
  let(:preview_token) { PreviewToken.new(project) }
  let(:project) { stub_model(Project) }

  it { preview_token.id.should eq("project_#{project.id}") }
  it { preview_token.token.should be_present }
  it { preview_token.to_s.should eq(preview_token.token) }
  it { preview_token.should == preview_token.token }

  it "can generate new token" do
    expect{preview_token.generate_token_value}.to change{preview_token.token}
  end

end
