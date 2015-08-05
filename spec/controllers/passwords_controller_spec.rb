require 'spec_helper'

describe PasswordsController do
  describe "GET new" do
    it "exists" do
      get :new
      response.should be_success
    end
  end
end
