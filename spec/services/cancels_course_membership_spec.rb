describe Services::CancelsCourseMembership do
  let(:course) { membership.course }
  let(:membership) { create(:course_membership, :student) }
  let(:student) { membership.user }

  describe ".call" do
    it "destroys the membership" do
      expect(Services::Actions::DestroysMembership).to receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the submissions for the student and course" do
      expect(Services::Actions::DestroysSubmissions).to receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the grades for the student and course" do
      expect(Services::Actions::DestroysGrades).to receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the assignment weights for the student and course" do
      expect(Services::Actions::DestroysAssignmentTypeWeights).to \
        receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the earned badges for the student and course" do
      expect(Services::Actions::DestroysEarnedBadges).to \
        receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the earned challenges for the student and course" do
      expect(Services::Actions::DestroysEarnedChallenges).to \
        receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the group memberships for the student and course" do
      expect(Services::Actions::DestroysGroupMemberships).to \
        receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the team memberships for the student and course" do
      expect(Services::Actions::DestroysTeamMemberships).to \
        receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the announcement states for the student and course" do
      expect(Services::Actions::DestroysAnnouncementStates).to \
        receive(:execute).and_call_original
      described_class.call membership
    end

    it "destroys the flagged users for the student and course" do
      expect(Services::Actions::DestroysFlaggedUsers).to \
        receive(:execute).and_call_original
      described_class.call membership
    end
  end
end
