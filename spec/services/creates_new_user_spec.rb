describe Services::CreatesNewUser do
  let(:user) { build :user }
  let(:params) { user.attributes }

  before do
    user_mailer = double(:user_mailer, activation_needed_email: double(:mailer, deliver_now: nil))
    stub_const "UserMailer", user_mailer
  end

  describe ".call" do
    it "initializes a new user" do
      expect(Services::Actions::BuildsUser).to receive(:execute).and_call_original
      described_class.call params
    end

    it "generates a password if they are not internal" do
      expect(Services::Actions::GeneratesPassword).to receive(:execute).and_call_original
      described_class.call params
    end

    it "updates user usernames and emails" do
      expect(Services::Actions::GeneratesUsernames).to receive(:execute).and_call_original
      described_class.call params
    end

    it "saves the user" do
      expect(Services::Actions::SavesUser).to receive(:execute).and_call_original
      described_class.call params
    end

    it "activates a user" do
      expect(Services::Actions::ActivatesUser).to receive(:execute).and_call_original
      described_class.call params
    end

    it "sends out an activation email" do
      expect(Services::Actions::SendsActivationNeededEmail).to receive(:execute).and_call_original
      described_class.call params
    end

    it "sends out a welcome email if needed" do
      expect(Services::Actions::SendsWelcomeEmail).to receive(:execute).and_call_original
      described_class.call params, true
    end
  end
end
