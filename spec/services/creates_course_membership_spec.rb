describe Services::CreatesCourseMembership do
  let(:course) { create :course }
  let(:user) { create :user }

  describe ".call" do
    it "creates the course membership" do
      expect(Services::Actions::CreatesCourseMembership).to receive(:execute).and_call_original
      described_class.call user, course
    end
  end
end
