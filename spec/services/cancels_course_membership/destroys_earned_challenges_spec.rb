require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_earned_challenges"

describe Services::Actions::DestroysEarnedChallenges do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the earned challenges to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the earned challenges" do
    another_earned_challenge = create :predicted_earned_challenge,
      student: student
    course_earned_challenge = create :predicted_earned_challenge,
      student: student, challenge: create(:challenge, course: course)
    described_class.execute membership: membership
    expect(PredictedEarnedChallenge.where(student_id: student.id)).to \
      eq [another_earned_challenge]
  end
end
