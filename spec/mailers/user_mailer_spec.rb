require 'spec_helper'

describe UserMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:user) { create :user, reset_password_token: "blah" }

  describe "reset_password_email" do
    before(:each) { UserMailer.reset_password_email(user).deliver_now }

    it "is sent from a notifications email" do
      expect(email.from).to eq ["mailer@gradecraft.com"]
    end

    it "is sent to the user's email" do
      expect(email.to).to eq [user.email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Your GradeCraft Password Reset Instructions"
    end

    it "has the password reset link" do
      expect(email.body).to include edit_password_url("blah")
    end
  end
end
