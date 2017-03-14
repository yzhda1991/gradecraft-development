describe Services::UpdatesUser do
  let(:user) { create :user }
  let(:params) { user.attributes.symbolize_keys }

  describe ".update" do
    it "updates the existing user" do
      expect(Services::Actions::UpdatesUser).to receive(:execute).and_call_original
      described_class.update user, params
    end
  end
end
