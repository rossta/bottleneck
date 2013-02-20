require 'spec_helper'

describe "Sessions API" do
  let(:user) { create(:user) }

  describe "/login POST" do
    it 'returns authenticates user with credentials' do
      previous_token = user.authentication_token

      post "/api/login", user: { email: user.email, password: user.password }

      user.reload

      user_json = user.active_model_serializer.new(user, root: 'user').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(user_json)

      user_json = JSON.parse(last_response.body)["user"]
      user_json["id"].should eq(user.id)
      user_json["name"].should eq(user.name)
      user_json["authentication_token"].should eq(user.authentication_token)
      previous_token.should_not eq(user.authentication_token)
    end

    it "returns unauthorized" do
      post "/api/login", user: { email: user.email, password: "tryingtohack" }

      last_response.status.should eq(401)
    end
  end

  describe "/logout" do
    it 'returns authenticates user with credentials' do
      user.reset_authentication_token!
      authenticated_delete "/api/logout", user.authentication_token

      user.reload

      last_response.status.should eq(200)
      last_response.body.should be_blank
      user.authentication_token.should be_nil
    end

    it "returns unauthorized" do
      authenticated_delete "/api/logout", "badtoken"

      last_response.status.should eq(406)
    end
  end

end
