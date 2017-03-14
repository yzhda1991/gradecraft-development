describe Services::Actions::DestroysAssignmentTypeWeights do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the assignment weights to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the assignment weights" do
    another_weight = create :assignment_type_weight, student: student
    course_weight = create :assignment_type_weight, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.assignment_type_weights).to eq [another_weight]
  end
end
