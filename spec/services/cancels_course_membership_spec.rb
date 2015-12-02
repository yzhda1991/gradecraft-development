require "active_record_spec_helper"
require "./app/services/cancels_course_membership"

describe Services::CancelsCourseMembership, focus: true do
  let(:course) { membership.course }
  let(:membership) { create(:student_course_membership) }
  let(:student) { membership.user }

  describe ".for_student" do
    it "destroys the membership" do
      expect(Services::Actions::DestroysMembership).to receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the submissions for the student and course" do
      expect(Services::Actions::DestroysSubmissions).to receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the grades for the student and course" do
      expect(Services::Actions::DestroysGrades).to receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the assignment weights for the student and course" do
      expect(Services::Actions::DestroysAssignmentWeights).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the earned badges for the student and course" do
      expect(Services::Actions::DestroysEarnedBadges).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the earned challenges for the student and course" do
      expect(Services::Actions::DestroysEarnedChallenges).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the group memberships for the student and course" do
      expect(Services::Actions::DestroysGroupMemberships).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the team memberships for the student and course" do
      expect(Services::Actions::DestroysTeamMemberships).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the announcement states for the student and course" do
      expect(Services::Actions::DestroysAnnouncementStates).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end

    it "destroys the flagged users for the student and course" do
      expect(Services::Actions::DestroysFlaggedUsers).to \
        receive(:execute).and_call_original
      described_class.for_student membership
    end
  end
end

describe CancelsCourseMembership do
  describe ".for_student" do
    let(:course) { membership.course }
    let(:membership) { create(:student_course_membership) }
    let(:student) { membership.user }

    it "removes the team memberships for the student" do
      another_team_membership = create :team_membership, student: student
      course_team_membership = create :team_membership, student: student,
        team: create(:team, course: course)
      described_class.for_student membership
      expect(TeamMembership.where(student_id: student.id)).to \
        eq [another_team_membership]
    end

    it "removes the announcement states for the student" do
      another_announcement = create :announcement_state, user: student
      course_announcement = create :announcement_state, user: student,
        announcement: create(:announcement, course: course)
      described_class.for_student membership
      expect(AnnouncementState.where(user_id: student.id)).to \
        eq [another_announcement]
    end

    it "removes the flagged states for the student" do
      another_flagger = create(:professor_course_membership)
      student.courses << another_flagger.course
      another_flagged_user = create :flagged_user, flagged: student,
        flagger: another_flagger.user, course: another_flagger.course
      flagger = create(:professor_course_membership, course: course)
      course_flagged_user = create :flagged_user, flagged: student,
        course: course, flagger: flagger.user
      described_class.for_student membership
      expect(FlaggedUser.where(flagged_id: student.id)).to \
        eq [another_flagged_user]
    end
  end
end
