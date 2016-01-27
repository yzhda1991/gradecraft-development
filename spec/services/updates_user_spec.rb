require "active_record_spec_helper"
require "./app/services/updates_user"

describe Services::UpdatesUser do
  let(:course) { create :course }
  let(:user) { create :user }
  let(:params) { user.attributes }

  describe ".update" do
    it "updates the existing user" do
      expect(Services::Actions::UpdatesUser).to receive(:execute).and_call_original
      described_class.update params, course
    end
  end
end
