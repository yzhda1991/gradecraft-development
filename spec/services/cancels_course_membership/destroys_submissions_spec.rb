describe Services::Actions::DestroysSubmissions do
  let(:course) { membership.course }
  let(:membership) { create :course_membership, :student }
  let(:student) { membership.user }

  it "expects the membership to find the submissions to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the submissions" do
    another_submission = create :submission, student: student
    course_submission = create :submission, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.submissions).to eq [another_submission]
  end
end
