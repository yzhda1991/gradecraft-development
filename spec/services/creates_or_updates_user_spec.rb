require "active_record_spec_helper"
require "./app/services/creates_or_updates_user"

describe Services::CreatesOrUpdatesUser do
  let(:course) { create :course }
  let(:user) { build :user }
  let(:params) { user.attributes }

  describe ".create_or_update" do
    it "decides if a user gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesUser).to receive(:execute).and_call_original
      described_class.create_or_update params, course
    end
  end
end
