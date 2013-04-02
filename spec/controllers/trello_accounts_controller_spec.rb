require 'spec_helper'

describe TrelloAccountsController do
  render_views

  describe "/callback", vcr: { record: :new_episodes, re_record_interval: 7.days } do
    it "redirects to new project path with trello account id" do
      access_token = mock("OAuth::AccessToken", token: "token", secret: "secret")
      request_token = mock("OAuth::RequestToken", get_access_token: access_token)

      request_token.should_receive(:get_access_token, with: { oauth_verifier: "8c9ff510665cb1459ee427c39b51a8bd" })
      controller.stub(request_token: request_token)
      controller.stub(current_user: stub_model(User))

      get :callback, {
        "oauth_token"=>"5d10861de99cf14953d58c9a30a51c4b",
        "oauth_verifier"=>"8c9ff510665cb1459ee427c39b51a8bd"
      }

      trello_account = controller.instance_variable_get("@trello_account")
      response.should redirect_to(new_project_path(trello_account_id: trello_account.id))
    end
  end
end
