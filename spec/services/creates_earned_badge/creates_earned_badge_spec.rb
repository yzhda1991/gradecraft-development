require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_earned_badge/creates_earned_badge"

describe Services::Actions::CreatesEarnedBadge do
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

  it "expects attributes to create the earned badge" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the created earned badge" do
    result = described_class.execute attributes: attributes
    expect(result).to have_key :earned_badge
    expect(result.earned_badge).to be_persisted
  end

  it "halts if the earned badge is invalid" do
    attributes[:student_id] = nil
    expect { described_class.execute attributes: attributes }.to \
      raise_error LightService::FailWithRollbackError
  end
end
