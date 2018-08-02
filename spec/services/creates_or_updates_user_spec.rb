describe Services::CreatesOrUpdatesUser do
  let(:course) { create :course }
  let(:user) { build :user }
  let(:params) { user.attributes }

  describe ".call" do
    it "decides if a user gets created or updated" do
      expect(Services::Actions::CreatesOrUpdatesUser).to receive(:execute).and_call_original
      described_class.call params, course
    end

    it "fails the context if create user service fails" do
      allow(Services::Actions::SavesUser).to receive(:execute).and_raise \
        LightService::FailWithRollbackError
      result = described_class.call params, course
      expect(result).to be_failure
    end

    it "fails the context if update user service fails" do
      allow(Services::Actions::UpdatesUser).to receive(:execute).and_raise \
        LightService::FailWithRollbackError
      result = described_class.call params, course
      expect(result).to be_failure
    end
  end
end
