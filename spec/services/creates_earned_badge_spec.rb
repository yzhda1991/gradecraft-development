require "active_record_spec_helper"
require "./app/services/creates_earned_badge"

describe Services::CreatesEarnedBadge do
  describe ".award" do
    let(:assignment) { create :assignment, course: course }
    let(:badge) { create :badge, course: course }
    let(:course) { create :course }
    let(:course_membership) { create :student_course_membership, course: course }
    let(:grade) { create :grade, course: course, student: student }
    let(:student) { course_membership.user }

    let(:attributes) do
      {
        student_id: student.id,
        badge_id: badge.id,
        assignment_id: assignment.id,
        grade_id: grade.id,
        score: 800,
        student_visible: true,
        feedback: "You are so awesome!"
      }
    end

    it "creates a new earned badge" do
      expect(Services::Actions::CreatesEarnedBadge).to \
        receive(:execute).and_call_original
      described_class.award attributes
    end

    it "recalculates the student's score" do
      expect(Services::Actions::RecalculatesStudentScore).to \
        receive(:execute).and_call_original
      described_class.award attributes
    end

    it "notifies the student of the awarded badge" do
      expect(Services::Actions::NotifiesOfEarnedBadge).to \
        receive(:execute).and_call_original
      described_class.award attributes
    end
  end
end
