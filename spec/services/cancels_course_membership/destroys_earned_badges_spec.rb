require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_earned_badges"

describe Services::Actions::DestroysEarnedBadges do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the earned badges to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the earned badges" do
    another_earned_badge = create :earned_badge, student: student
    course_earned_badge = create :earned_badge, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.earned_badges).to eq [another_earned_badge]
  end

  it "destroys the predicted earned badges" do
    another_earned_badge = create :predicted_earned_badge, student: student
    course_earned_badge = create :predicted_earned_badge, student: student,
      badge: create(:badge, course: course)
    described_class.execute membership: membership
    expect(PredictedEarnedBadge.where(student_id: student.id)).to \
      eq [another_earned_badge]
  end
end
