require 'rails_spec_helper'

describe NotificationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:admin_email) { NotificationMailer::ADMIN_EMAIL }

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
      it "includes the user's name" do
        should include user.name
      end

      it "includes the user's email" do
        should include user.email
      end

      it "includes the user's lti_uid" do
        should include user.lti_uid
      end

      it "includes the course name" do
        should include course.name
      end

      it "includes the course lti_uid" do
        should include course.lti_uid
      end
    end
  end
end
