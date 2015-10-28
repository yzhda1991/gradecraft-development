require "active_record_spec_helper"
require "./app/services/cancels_course_membership"

describe CancelsCourseMembership do
  describe ".for_student" do
    let(:membership) { create(:student_course_membership) }

    it "removes the course membership" do
      described_class.for_student membership
      expect(CourseMembership.exists?(membership.id)).to eq false
    end

    it "removes the grades for the student" do
      create :grade, student: membership.user, course: membership.course
      described_class.for_student membership
      expect(membership.user.reload.grades).to be_empty
    end

    it "removes the rubric grades for the student" do
      create :rubric_grade, student: membership.user
      described_class.for_student membership
      expect(RubricGrade.where(student_id: membership.user.id)).to be_empty
    end

    xit "removes the assignment weights for the student"
    xit "removes the assignment type weights for the student"
    xit "removes the submissions for the student"
    xit "removes the earned badges for the student"
    xit "removes the predicted earned badges for the student"
    xit "removes the predicted earned challenges for the student"
    xit "removes the group memberships for the student"
    xit "removes the team memberships for the student"
    xit "removes the announcement states for the student"
    xit "removes the flagged states for the student"
  end
end
