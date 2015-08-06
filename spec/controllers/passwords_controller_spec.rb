require 'spec_helper'

describe PasswordsController do
  describe "GET new" do
    it "exists" do
      get :new
      expect(response).to be_success
    end
  end

  describe "POST create" do
    let(:user) { create :user }

    it "creates a password reset token for the user" do
      post :create, email: user.email
      expect(user.reload.reset_password_token).to_not be_nil
    end

    it "sends the user an email with password reset instructions" do
      expect { post :create, email: user.email.upcase }.to \
        change { ActionMailer::Base.deliveries.count }.by 1
      expect(response).to be_redirect
    end
  end

  describe "GET edit" do
    let(:user) { create :user, reset_password_token: "blah" }

    it "exists" do
      get :edit, id: user.reset_password_token
      expect(response).to be_success
    end

    it "redirects to the root url if the token is not correct" do
      get :edit, id: "blech"
      expect(response).to be_redirect
    end

    it "redirects to the root url if the token has expired" do
      user.update_attribute :reset_password_token_expires_at, 1.hour.ago
      get :edit, id: user.reset_password_token
      expect(response).to be_redirect
    end
  end

  describe "PUT update" do
    let(:user) { create :user, reset_password_token: "blah" }

    it "changes the user's password" do
      put :update, id: user.reset_password_token, token: user.reset_password_token, user: { password: "blah", password_confirmation: "blah" }
      expect(User.authenticate(user.email, "blah")).to eq user
    end

    xit "logs the user in"

    context "with non-matching password" do
      xit "renders the edit template with the error"
    end

    context "with a blank password" do
      xit "renders the edit template with the error"
    end
  end
end
