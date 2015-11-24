require "active_record_spec_helper"
require "./app/services/creates_new_user"

describe Services::CreatesNewUser do
  let(:user) { build :user }
  let(:params) { user.attributes }

  describe ".create" do
    it "initializes a new user" do
      expect(Services::Actions::BuildsUser).to receive(:execute).and_call_original
      described_class.create params
    end

    it "generates a password if they are not internal" do
      expect(Services::Actions::GeneratesPassword).to receive(:execute).and_call_original
      described_class.create params
    end

    it "updates internal user" do
      expect(Services::Actions::InternalizesUser).to receive(:execute).and_call_original
      described_class.create params
    end

    it "saves the user" do
      expect(Services::Actions::SavesUser).to receive(:execute).and_call_original
      described_class.create params
    end

    it "activates a user" do
      expect(Services::Actions::ActivatesUser).to receive(:execute).and_call_original
      described_class.create params
    end

    xit "sends out an activation email if needed"
    xit "sends out a welcome email if needed"
  end
end
