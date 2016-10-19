require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_earned_badge/updates_earned_badges_for_grade"

describe Services::Actions::UpdatesEarnedBadgesForGrade do
  let(:course) { create :course }
  let(:assignment) { create :assignment, course: course }
  let(:student) { create(:student_course_membership, course: course).user }
  let!(:grade) { create :released_grade, student: student, assignment: assignment }
  let(:badge) { create :badge, course: course }
  let!(:earned_badge) { create :earned_badge, badge: badge, grade: grade, student_visible: false }


  it "expects attributes to have a grade" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "updates the earned badge with the correct awarded_by" do
    described_class.execute grade: grade
    expect(earned_badge.student_visible).to be_truthy
  end
end
