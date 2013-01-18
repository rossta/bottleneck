require 'spec_helper'

describe HomeController do

  describe "GET 'index'" do
    before(:each) do
      get :index
    end
    it { should respond_with_content_type :html }
  end

end
