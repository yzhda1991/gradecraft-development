require 'rails_spec_helper'

describe NotificationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { "GradeCraft <mailer@gradecraft.com>" }
  let(:admin_email) { "cholma@umich.edu" }

  describe "#lti_error" do
    let(:user) { create :user, lti_uid: rand(100) }
    let(:course) { create :course, lti_uid: rand(100) }

    before(:each) do
      NotificationMailer.lti_error(user, course).deliver_now
    end

    it "is sent from the author's email" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the student's email" do
      expect(email.to).to eq [admin_email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Unknown LTI user/course"
    end

    describe "email body" do
      subject { email.body }
      it { is_expected.to include user.name }
      it { is_expected.to include user.email }
      it { is_expected.to include user.lti_uid }
      it { is_expected.to include course.name }
      it { is_expected.to include course.lti_uid }
    end
  end
end
