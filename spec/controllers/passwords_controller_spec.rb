require 'spec_helper'

describe PasswordsController do
  describe "GET new" do
    it "exists" do
      get :new
      response.should be_success
    end
  end

  describe "POST create" do
    context "with a valid email address" do
      let(:user) { create :user }

      it "sends the user an email with password reset instructions" do
        expect { post :create, email: user.email }.to \
          change { ActionMailer::Base.deliveries.count }.by 1
        response.should be_redirect
      end
    end
  end
end
