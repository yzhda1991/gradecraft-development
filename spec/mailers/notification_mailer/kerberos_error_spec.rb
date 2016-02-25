require "rails_spec_helper"

describe NotificationMailer do
  let(:email) { ActionMailer::Base.deliveries.last }
  let(:sender) { NotificationMailer::SENDER_EMAIL }
  let(:admin_email) { NotificationMailer::ADMIN_EMAIL }

  describe "#kerberos_error" do
    # just a UID passed in from the auth hash in sessions
    # this is not modeling a real user
    let(:kerberos_uid) { rand(1000) }

    before(:each) do
      NotificationMailer.kerberos_error(kerberos_uid).deliver_now
    end

    it "is sent from the gradecraft default sender" do
      expect(email.from).to eq [sender]
    end

    it "is sent to the gradecraft admin" do
      expect(email.to).to eq [admin_email]
    end

    it "has an appropriate subject" do
      expect(email.subject).to eq "Unknown Kerberos user"
    end

    describe "email body" do
      subject { email.body }

      it "includes the provided kerberos uid" do
        should include kerberos_uid
      end
    end
  end
end
