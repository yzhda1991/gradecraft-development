require 'rails_spec_helper'

describe NotificationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:admin_email) { NotificationMailer::ADMIN_EMAIL }

  describe "#lti_error" do
    let(:user_data) { FactoryGirl.attributes_for(:user).merge(lti_uid: rand(100)) }
    let(:course_data) { FactoryGirl.attributes_for(:course).merge(lti_uid: rand(100)) }

    before(:each) do
      NotificationMailer.lti_error(user_data, course_data).deliver_now
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
        should include user_data[:name]
      end

      it "includes the user's email" do
        should include user_data[:email]
      end

      it "includes the user's lti_uid" do
        should include user_data[:lti_uid]
      end

      it "includes the course name" do
        should include course_data[:name]
      end

      it "includes the course lti_uid" do
        should include course_data[:lti_uid]
      end
    end
  end
end
