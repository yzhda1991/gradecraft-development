describe Services::UpdatesUserForCourse do
  let(:course) { create :course }
  let(:user) { create :user }
  let(:params) { user.attributes.symbolize_keys }

  describe ".call" do
    it "updates the existing user" do
      expect(Services::Actions::UpdatesUser).to receive(:execute).and_call_original
      described_class.call user, params, course
    end

    it "creates the course membership with the user and course" do
      expect(Services::Actions::CreatesCourseMembership).to receive(:execute).and_call_original
      described_class.call user, params, course
    end
  end
end
