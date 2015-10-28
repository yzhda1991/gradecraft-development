require "active_record_spec_helper"
require "./app/services/cancels_course_membership"

describe CancelsCourseMembership do
  describe ".for_student" do
    let(:course) { membership.course }
    let(:membership) { create(:student_course_membership) }
    let(:student) { membership.user }

    it "removes the course membership" do
      described_class.for_student membership
      expect(CourseMembership.exists?(membership.id)).to eq false
    end

    it "removes the grades for the student and course" do
      another_grade = create :grade, student: student
      course_grade = create :grade, student: student, course: course
      described_class.for_student membership
      expect(student.reload.grades).to eq [another_grade]
    end

    it "removes the submissions for the student" do
      another_submission = create :submission, student: student
      course_submission = create :submission, student: student, course: course
      described_class.for_student membership
      expect(student.reload.submissions).to eq [another_submission]
    end

    it "removes the rubric grades for the student and course submissions" do
      another_submission = create :submission, student: student
      course_submission = create :submission, student: student, course: course
      another_grade = create :rubric_grade, submission: another_submission,
        student: student
      course_grade = create :rubric_grade, submission: course_submission,
        student: student
      described_class.for_student membership
      expect(RubricGrade.for_student(membership.user)).to eq [another_grade]
    end

    it "removes the rubric grades for the student and course assignments" do
      course_assignment = create :assignment, course: course
      another_grade = create :rubric_grade, student: student
      course_grade = create :rubric_grade, assignment: course_assignment,
        student: student
      described_class.for_student membership
      expect(RubricGrade.for_student(membership.user)).to eq [another_grade]
    end

    xit "removes the assignment weights for the student"
    xit "removes the assignment type weights for the student"
    xit "removes the earned badges for the student"
    xit "removes the predicted earned badges for the student"
    xit "removes the predicted earned challenges for the student"
    xit "removes the group memberships for the student"
    xit "removes the team memberships for the student"
    xit "removes the announcement states for the student"
    xit "removes the flagged states for the student"
  end
end
