require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_assignment_weights"

describe Services::Actions::DestroysAssignmentWeights do
  let(:course) { membership.course }
  let(:membership) { create :student_course_membership }
  let(:student) { membership.user }

  it "expects the membership to find the assignment weights to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the assignment weights" do
    another_assignment_weight = create :assignment_weight, student: student
    course_assignment_weight = create :assignment_weight, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.assignment_weights).to eq [another_assignment_weight]
  end
end
