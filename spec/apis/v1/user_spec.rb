require 'spec_helper'

describe "Users Api" do
  let(:user) { create(:user) }

  describe "/users/me" do
    it 'returns user for given token' do
      authenticated_get "/api/users/me", user.authentication_token

      user_json = user.active_model_serializer.new(user, root: 'user').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(user_json)

      user_json = JSON.parse(last_response.body)["user"]
      user_json["id"].should eq(user.id)
      user_json["name"].should eq(user.name)
    end

    it "returns unauthorized" do
      authenticated_get '/api/users/me', 'badtoken'

      last_response.status.should eq(406)
    end
  end

  describe "/users/:name" do
    it 'returns user for given token' do
      authenticated_get "/api/users/#{user.id}", user.authentication_token

      user_json = user.active_model_serializer.new(user, root: 'user').to_json
      last_response.status.should eq(200)
      last_response.body.should eq(user_json)

      user_json = JSON.parse(last_response.body)["user"]
      user_json["id"].should eq(user.id)
      user_json["name"].should eq(user.name)
    end

    it "returns unauthorized" do
      authenticated_get "/api/users/#{user.id}", 'badtoken'

      last_response.status.should eq(406)
    end
  end
end
